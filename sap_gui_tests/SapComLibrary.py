import os
import re
import subprocess
import time
from pathlib import Path

import win32com.client

TRACE_DIR = Path(os.environ.get("LOCALAPPDATA", "")) / "SAP" / "SAP GUI" / "Traces"


class SapComLibrary:
    """Direct, reliable COM wrapper for 64-bit SAP GUI Scripting.

    The attached session is stored on the class so that every library instance
    shares it: Robot Framework imports this library separately for each resource
    file, but the SAP GUI session itself is global.
    """

    session = None

    # ------------------------------------------------------------------
    # Connection handling
    # ------------------------------------------------------------------

    @staticmethod
    def _last_scripting_disabled_trace_line(max_age: float = 15.0):
        """Return the last 'Scripting not enabled' line from a recent SAP GUI trace."""
        try:
            traces = sorted(
                TRACE_DIR.glob("sapfewdll_*.err.trc"),
                key=lambda path: path.stat().st_mtime,
                reverse=True,
            )
        except OSError:
            return None

        now = time.time()
        for path in traces[:3]:
            try:
                if now - path.stat().st_mtime > max_age:
                    continue
                lines = path.read_text(encoding="latin-1", errors="ignore").splitlines()
            except OSError:
                continue
            for line in reversed(lines[-80:]):
                if "scripting not enabled" in line.lower():
                    return line.strip()
        return None

    @staticmethod
    def _backend_scripting_message(trace_line: str = "") -> str:
        detail = f" SAP GUI trace: '{trace_line}'." if trace_line else ""
        return (
            "SAP GUI session cannot be attached: the SAP application server reports "
            "'Scripting not enabled by backend for this session'. "
            "Enable SAP GUI scripting on the server (RZ11: sapgui/user_scripting = TRUE; "
            "check sapgui/user_scripting_per_user) and open a new SAP GUI session." + detail
        )

    def _require_session(self):
        if SapComLibrary.session is None:
            raise RuntimeError(
                "No active SAP GUI session is attached. Run 'Connect To Active Session' "
                "first, and make sure SAP GUI is running with scripting enabled on the "
                "application server (RZ11: sapgui/user_scripting = TRUE)."
            )
        return SapComLibrary.session

    def kill_existing_sap_processes(self) -> None:
        for proc in ("sapshcut.exe", "sapgui.exe", "saplogon.exe"):
            subprocess.run(
                ["taskkill", "/F", "/IM", proc],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=False,
            )
        time.sleep(1.0)

    def connect_to_active_session(self, timeout: float = 30.0) -> None:
        SapComLibrary.session = None
        deadline = time.time() + float(timeout)
        last_getobject_err = None
        last_engine_err = None

        while time.time() < deadline:
            try:
                sap_gui = win32com.client.GetObject("SAPGUI")
            except Exception as err:
                last_getobject_err = err
                trace_line = self._last_scripting_disabled_trace_line()
                if trace_line:
                    raise RuntimeError(self._backend_scripting_message(trace_line)) from err
                time.sleep(0.5)
                continue

            try:
                engine = sap_gui.GetScriptingEngine
            except Exception as err:
                last_engine_err = err
                trace_line = self._last_scripting_disabled_trace_line()
                if trace_line:
                    raise RuntimeError(self._backend_scripting_message(trace_line)) from err
                time.sleep(0.5)
                continue

            try:
                if engine.Children.Count > 0:
                    conn = engine.Children(0)
                    if conn.Children.Count > 0:
                        SapComLibrary.session = conn.Children(0)
                        return
            except Exception as err:
                last_engine_err = err

            time.sleep(0.5)

        raise RuntimeError(
            f"Could not attach to SAP GUI session within {timeout}s. "
            f"Last GetObject error: {last_getobject_err!r}. "
            f"Last GetScriptingEngine error: {last_engine_err!r}."
        )

    def element_should_be_present(self, element_id: str) -> None:
        self._require_session().FindById(element_id)

    def input_text(self, element_id: str, text: str) -> None:
        self._require_session().FindById(element_id).Text = str(text)

    def input_password(self, element_id: str, password: str) -> None:
        self._require_session().FindById(element_id).Text = str(password)

    def get_text(self, element_id: str) -> str:
        return str(self._require_session().FindById(element_id).Text)

    def click_element(self, element_id: str) -> None:
        self._require_session().FindById(element_id).Press()

    def send_vkey(self, vkey: int = 0) -> None:
        self._require_session().FindById("wnd[0]").SendVKey(int(vkey))

    def run_transaction(self, tcode: str) -> None:
        session = self._require_session()
        session.FindById("wnd[0]/tbar[0]/okcd").Text = str(tcode)
        session.FindById("wnd[0]").SendVKey(0)

    def get_statusbar_message(self) -> str:
        return str(self._require_session().FindById("wnd[0]/sbar").Text)

    def get_statusbar_type(self) -> str:
        return str(self._require_session().FindById("wnd[0]/sbar").MessageType)

    def grid_row_count(self, element_id: str) -> int:
        return int(self._require_session().FindById(element_id).RowCount)

    def acknowledge_warnings_and_popups(self, max_attempts: int = 5) -> None:
        session = self._require_session()
        for _ in range(int(max_attempts)):
            handled = False
            try:
                session.FindById("wnd[1]")
                session.FindById("wnd[1]").SendVKey(0)
                handled = True
            except Exception:
                pass

            msg_type = self.get_statusbar_type()
            if msg_type == "E":
                raise AssertionError(f"SAP Error blocking progress: {self.get_statusbar_message()}")
            if msg_type == "W":
                session.FindById("wnd[0]").SendVKey(0)
                handled = True

            if not handled:
                break

    @classmethod
    def _describe_element(cls, element, depth: int = 0) -> str:
        try:
            element_id = getattr(element, "Id", "")
            element_type = getattr(element, "Type", "")
            text = getattr(element, "Text", "")
        except Exception:
            return ""

        indent = "  " * depth
        desc = f"{indent}{element_id} [{element_type}] {text!r}"
        if depth >= 2:
            return desc

        try:
            children = element.Children
            count = int(children.Count)
        except Exception:
            return desc

        for index in range(min(count, 30)):
            try:
                child = children.Item(index)
            except Exception:
                continue
            desc += "\n" + cls._describe_element(child, depth + 1)
        return desc

    def save_document(self, timeout: float = 15.0) -> None:
        session = self._require_session()
        self.acknowledge_warnings_and_popups()
        save_btn = session.FindById("wnd[0]/tbar[0]/btn[11]")
        if not save_btn.Changeable:
            session.FindById("wnd[0]").SendVKey(0)
            self.acknowledge_warnings_and_popups()

        save_btn.Press()

        deadline = time.time() + float(timeout)
        last_popup_title = ""
        last_popup_tree = ""
        last_statusbar = ""
        last_type = ""
        while time.time() < deadline:
            try:
                popup = session.FindById("wnd[1]")
                popup_title = getattr(popup, "Text", "")
                last_popup_title = popup_title
                last_popup_tree = self._describe_element(popup)
                if "Incomplete" in popup_title or "Unvollständig" in popup_title:
                    # Press 'Save' inside Incompletion Log popup
                    popup.SendVKey(11)
                else:
                    popup.SendVKey(0)
                time.sleep(0.3)
                continue
            except Exception:
                pass

            last_statusbar = self.get_statusbar_message()
            last_type = self.get_statusbar_type()
            if last_type == "E":
                raise AssertionError(f"SAP Save Error: {last_statusbar}")
            if last_statusbar and re.search(r"\b\d{5,12}\b", last_statusbar):
                return
            time.sleep(0.3)

        raise AssertionError(
            f"Document did not save within {timeout}s. "
            f"Last popup title: '{last_popup_title}'. "
            f"Last statusbar type: '{last_type}'. "
            f"Last statusbar: '{last_statusbar}'.\n"
            f"Popup element tree:\n{last_popup_tree}"
        )

    def extract_document_number_from_statusbar(self) -> str:
        msg = self.get_statusbar_message()
        match = re.search(r"\b(\d{5,12})\b", msg)
        if not match:
            raise AssertionError(f"No document number found in statusbar: '{msg}'")
        return match.group(1)

    def dismiss_popup_if_present(self) -> None:
        session = self._require_session()
        try:
            popup = session.FindById("wnd[1]")
        except Exception:
            return
        popup.SendVKey(0)

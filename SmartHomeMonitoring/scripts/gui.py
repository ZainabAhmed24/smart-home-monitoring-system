import tkinter as tk
from tkinter import ttk, messagebox
import os
import subprocess

# Global variables
USERNAME = "admin"
PASSWORD = "1234"

# Paths to logs
LOGS = {
    "Appliance Log": "/root/SmartHomeMonitoring/logs/appliance.log",
    "Garden Log": "/root/SmartHomeMonitoring/logs/garden.log",
    "Indoor Climate Log": "/root/SmartHomeMonitoring/logs/indoor_climate.log",
    "Outdoor Lighting Log": "/root/SmartHomeMonitoring/logs/outdoor_lighting.log",
    "Security Log": "/root/SmartHomeMonitoring/logs/security.log",
    "Weather Log": "/root/SmartHomeMonitoring/logs/weather.log",
    "Doorbell Log": "/root/SmartHomeMonitoring/logs/doorbell.log",
    "Indoor Camera Log": "/root/SmartHomeMonitoring/logs/indoor_camera.log",
    "Lighting Log": "/root/SmartHomeMonitoring/logs/lighting.log",
    "Outdoor Security Log": "/root/SmartHomeMonitoring/logs/outdoor_security.log",
    "System Metrics Log": "/root/SmartHomeMonitoring/logs/system_metrics.log",
}

# Function to handle login
def login():
    def check_login(event=None):
        user = username_entry.get()
        pwd = password_entry.get()
        if user == USERNAME and pwd == PASSWORD:
            login_window.destroy()
            main_menu()
        else:
            messagebox.showerror("Login Failed", "Incorrect username or password!")

    # Login window
    login_window = tk.Tk()
    login_window.title("Login - Smart Home Monitoring")
    login_window.geometry("300x150")
    login_window.resizable(False, False)

    tk.Label(login_window, text="Username").pack(pady=5)
    username_entry = tk.Entry(login_window)
    username_entry.pack()
    username_entry.focus_set()  # Focus on the username field by default

    tk.Label(login_window, text="Password").pack(pady=5)
    password_entry = tk.Entry(login_window, show="*")
    password_entry.pack()

    login_button = tk.Button(login_window, text="Login", command=check_login)
    login_button.pack(pady=10)

    # Bind Enter key to the login button
    login_window.bind("<Return>", check_login)
    login_window.mainloop()

def view_recent_alerts():
    def show_alerts(alerts, title="Alerts"):
        """Helper function to display alerts in a new window."""
        alerts_window = tk.Toplevel()
        alerts_window.title(title)
        alerts_window.geometry("600x400")

        # Title Label
        tk.Label(alerts_window, text=title, font=("Helvetica", 16, "bold")).pack(pady=10)

        # Frame for the Text widget and scrollbar
        text_frame = tk.Frame(alerts_window)
        text_frame.pack(fill="both", expand=True, padx=10, pady=(0, 10))  # Padding added at bottom

        # Scrollbar for the Text widget
        scrollbar = ttk.Scrollbar(text_frame, orient="vertical")
        alerts_text = tk.Text(
            text_frame, wrap="word", yscrollcommand=scrollbar.set, height=15
        )
        scrollbar.config(command=alerts_text.yview)
        scrollbar.pack(side="right", fill="y")
        alerts_text.pack(side="left", fill="both", expand=True)

        # Insert alerts into the Text widget
        if alerts:
            for alert in alerts:
                alerts_text.insert(tk.END, alert + "\n")
        else:
            alerts_text.insert(tk.END, "No alerts found.")

        alerts_text.config(state="disabled")  # Make the Text widget read-only

        # Button frame at the bottom of the window
        button_frame = tk.Frame(alerts_window)
        button_frame.pack(fill="x", pady=(0, 10))  # No padding at the top, padding at the bottom

        if title == "Latest 20 Alerts":
            tk.Button(
                button_frame,
                text="See All",
                command=lambda: show_alerts(fetch_alerts(), title="All Alerts"),
                font=("Helvetica", 12),
                bg="#f0f0f0",
                pady=5,
            ).pack(side="left", padx=5)

        tk.Button(
            button_frame,
            text="Close",
            command=alerts_window.destroy,
            font=("Helvetica", 12),
            bg="#f0f0f0",
            pady=5,
        ).pack(side="right", padx=5)

    def fetch_alerts(limit=None):
        """Fetch alerts from the log file."""
        alert_log_path = "/root/SmartHomeMonitoring/alerts/alert_log.log"
        if not os.path.exists(alert_log_path):
            return []

        with open(alert_log_path, "r") as f:
            alerts = f.readlines()

        alerts = [alert.strip() for alert in alerts]  # Remove newlines and whitespace
        alerts.reverse()  # Reverse order for latest-first display

        if limit:
            alerts = alerts[:limit]

        return alerts

    # Fetch the latest 20 alerts and display them
    recent_alerts = fetch_alerts(limit=20)
    show_alerts(recent_alerts, title="Latest 20 Alerts")


# Function to view all logs with centered button text
def view_all_logs():
    def open_log(log_name):
        log_path = LOGS[log_name]
        log_window = tk.Toplevel()
        log_window.title(f"{log_name}")
        log_window.geometry("600x400")

        tk.Label(log_window, text=f"{log_name}", font=("Helvetica", 16, "bold")).pack(pady=10)

        log_text = tk.Text(log_window, wrap="word", height=20, width=60)
        log_text.pack(pady=10)
        if os.path.exists(log_path):
            with open(log_path, "r") as f:
                log_text.insert(tk.END, f.read())
        else:
            log_text.insert(tk.END, "Log not found.")
        tk.Button(log_window, text="Close", command=log_window.destroy).pack(pady=10)

    logs_window = tk.Toplevel()
    logs_window.title("All Logs")
    logs_window.geometry("300x300")  # Shorter window size

    tk.Label(logs_window, text="Logs", font=("Helvetica", 16, "bold")).pack(pady=10)

    # Scrollable frame setup
    container = ttk.Frame(logs_window)
    canvas = tk.Canvas(container, highlightthickness=0, width=380)  # Remove border, set width for centering
    scrollbar = ttk.Scrollbar(container, orient="vertical", command=canvas.yview)
    scrollable_frame = ttk.Frame(canvas)

    def _on_mousewheel(event):
        canvas.yview_scroll(int(-1 * (event.delta / 120)), "units")

    def _on_scroll_linux(event):
        if event.num == 4:  # Up
            canvas.yview_scroll(-1, "units")
        elif event.num == 5:  # Down
            canvas.yview_scroll(1, "units")

    scrollable_frame.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
    canvas.create_window((0, 0), window=scrollable_frame, anchor="n", width=360)  # Centering inside canvas

    canvas.configure(yscrollcommand=scrollbar.set)

    container.pack(fill="both", expand=True, padx=10, pady=10)
    canvas.pack(side="left", fill="both", expand=True)
    scrollbar.pack(side="right", fill="y")

    logs_window.bind("<MouseWheel>", _on_mousewheel)
    logs_window.bind("<Button-4>", _on_scroll_linux)  # Trackpad (Linux up)
    logs_window.bind("<Button-5>", _on_scroll_linux)  # Trackpad (Linux down)

    # Add buttons for each log
    for log_name in LOGS:
        btn = tk.Button(
            scrollable_frame,
            text=log_name,
            font=("Helvetica", 12),
            anchor="center",
            justify="center",
            command=lambda ln=log_name: open_log(ln)
        )
        btn.pack(pady=5, padx=0, fill="x")  # No horizontal padding for better centering
        btn.bind("<Return>", lambda event, ln=log_name: open_log(ln))

# Function to send a test Slack notification
def send_test_slack():
    webhook_url = "https://hooks.slack.com/services/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"
    subprocess.run(["curl", "-X", "POST", "-H", "Content-type: application/json",
                    "--data", '{"text":"Test Slack Notification from Smart Home!"}', webhook_url])
    messagebox.showinfo("Slack", "Test Slack notification sent.")

# Main Menu
def main_menu():
    root = tk.Tk()
    root.title("Smart Home Monitoring")
    root.geometry("500x400")
    root.configure(bg="#f0f0f0")

    title_label = tk.Label(root, text="Smart Home Monitoring", font=("Helvetica", 18, "bold"), bg="#f0f0f0", fg="#333")
    title_label.pack(pady=20)

    button_frame = ttk.Frame(root, padding="10")
    button_frame.pack(fill="both", expand=True)

    ttk.Button(button_frame, text="View Recent Alerts", command=view_recent_alerts, width=25).pack(pady=10)
    ttk.Button(button_frame, text="View All Logs", command=view_all_logs, width=25).pack(pady=10)
    ttk.Button(button_frame, text="Send Test Slack Notification", command=send_test_slack, width=25).pack(pady=10)
    ttk.Button(button_frame, text="Exit", command=root.quit, width=25).pack(pady=10)

    style = ttk.Style()
    style.configure("TButton", font=("Helvetica", 12), padding=6)

    root.mainloop()

# Start the program with the login screen
login()

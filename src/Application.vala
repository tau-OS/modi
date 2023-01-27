namespace Modi {
	public static MainWindow? main_window;
	public class Application : He.Application {
		public static int main (string[] args) {
			Intl.setlocale ();
			var app = new Application (Config.APP_ID, ApplicationFlags.HANDLES_OPEN);
			return app.run (args);
		}

		public Application (string? application_id, ApplicationFlags flags) {
			base (application_id, flags);
			this.application_id = application_id;
			this.flags = flags;
		}

		protected override void startup () {
			Gdk.RGBA accent_color = { 0 };
			accent_color.parse("#E0A101");
			default_accent_color = He.Color.from_gdk_rgba(accent_color);

			resource_base_path = "/co/tauos/Modi";
			setup_actions ();

			typeof (Viewer).ensure ();
			typeof (PictureFile).ensure ();
			base.startup ();
		}

		protected override void activate () {
			var window = get_last_window ();
			if (window == null) {
				window = new MainWindow (this);
				window.show ();
			} else {
				window.present ();
			}
			base.activate ();
		}

		public override void open (File[] files, string hint) {
			base.open (files, hint);
			var window = get_last_window ();
			if (window == null) {
				window = new MainWindow (this);
				window.load_project(files[0]);
				window.show ();
			} else {
				window.present ();
			}
		}

		protected void setup_actions () {
			var about_action = new SimpleAction ("about", null);
			about_action.activate.connect (v => {
				show_about_dialog ();
			});

			add_action (about_action);
		}

		protected void show_about_dialog () {
			var about = new He.AboutWindow (
				get_last_window (),
				"Modi" + Config.NAME_SUFFIX,
				Config.APP_ID,
				Config.VERSION,
				Config.APP_ID,
				"https://github.com/tau-OS/modi/tree/main/po",
				"https://github.com/tau-OS/modi/issues",
				"catalogue://co.tauos.Modi",
				{},
				{"Lains", "Lea"},
				2022,
				He.AboutWindow.Licenses.GPLv3,
				He.Colors.YELLOW
			);
			about.present ();
		}

		public MainWindow? get_last_window () {
			unowned List<Gtk.Window> windows = get_windows ();
			return windows.length () > 0 ? windows.last ().data as MainWindow : null;
		}
	}
}

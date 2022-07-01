namespace Modi {
	public static MainWindow? main_window;
	public class Application : He.Application {

		public static int main (string[] args) {
			Intl.setlocale ();
			var app = new Application (Config.APP_ID, ApplicationFlags.HANDLES_OPEN);
			return app.run (args);
		}

		public Application (string? application_id, ApplicationFlags flags) {
			this.application_id = application_id;
			this.flags = flags;
			base (application_id, flags);
		}

		protected override void startup () {
			resource_base_path = "/co/tauos/Modi";

			base.startup ();
			setup_actions ();

			typeof (Viewer).ensure ();
			typeof (PictureFile).ensure ();

			main_window = new MainWindow (this);
			add_window (main_window);
		}

		protected override void activate () {
			base.activate ();
		}

		public override void open (File[] files, string hint) {
			base.open (files, hint);
			main_window.load_project (files[0]);
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
				main_window,
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
	}
}

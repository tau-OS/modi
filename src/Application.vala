namespace App {
	public static Window.Main? main_window;
	public class Instance : He.Application {

		construct {
			application_id = Config.APP_ID;
			flags = ApplicationFlags.HANDLES_OPEN;
		}

		public static int main (string[] args) {
			Intl.setlocale ();
			var app = new Instance ();
			return app.run (args);
		}

		protected override void startup () {
			resource_base_path = "/co/tauos/Modi";

			base.startup ();
			setup_actions ();

			main_window = new Window.Main (this);
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
			set_accels_for_action ("app.about", { "F1" });
		}

		protected void show_about_dialog () {
			//  TODO: show about dialog
		}

	}

}

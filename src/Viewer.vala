[GtkTemplate (ui = "/co/tauos/Modi/viewer.ui")]
public class Modi.Viewer : He.ViewMono {
	public MainWindow window { get; set; }
	public PictureFile? project {
		get { return canvas.project; }
		set { canvas.project = value; }
	}

	protected Canvas canvas;

	[GtkChild]
	new unowned Gtk.Stack stack;
	[GtkChild]
	unowned He.OverlayButton overlay_button;
	[GtkChild]
	unowned Gtk.ScrolledWindow sw;
	[GtkChild]
	unowned He.EmptyPage empty_page;

	public class Viewer (MainWindow? window) {
		this.window = window;
		window.render.connect (() => {
			canvas.queue_draw ();
		});
		notify["project"].connect (on_project_changed);
	}
	
	construct {
		canvas = new Canvas ();

		overlay_button.typeb = He.OverlayButton.TypeButton.PRIMARY;
		overlay_button.typeb2 = He.OverlayButton.TypeButton.SECONDARY;

		overlay_button.clicked.connect (() => {
			zoom_in ();
		});
		overlay_button.secondary_clicked.connect (() => {
			zoom_out ();
		});

		sw.child = canvas;

		empty_page.action_button.clicked.connect(() => {
			window.open_file ();
		});
	}

	void on_project_changed () {
		var is_empty = (project == null);

		stack.visible_child_name = is_empty ? "empty" : "canvas";

		if (is_empty)
			this.remove_css_class ("editor-bg");
		else
			this.add_css_class ("editor-bg");
	}

	public void zoom_in () {
		canvas.scale += float.parse("0.1");
	}

	public void zoom_out () {
		if (canvas.scale >= 0.0) {
			canvas.scale -= float.parse("0.1");
		} else {
			canvas.scale = float.parse("0.1");
		}
	}
}

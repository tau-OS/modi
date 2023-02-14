[GtkTemplate (ui = "/com/fyralabs/Modi/viewer.ui")]
public class Modi.Viewer : He.Bin {
	public MainWindow window { get; set; }
	public PictureFile? project {
		get { return canvas.project; }
		set { canvas.project = value; }
	}

	protected Canvas canvas;

	[GtkChild]
	new unowned Gtk.Stack stack;
	[GtkChild]
	unowned He.IconicButton zoomout;
	[GtkChild]
	unowned He.IconicButton zoomin;
	[GtkChild]
	unowned He.IconicButton fullscreen;
	[GtkChild]
	unowned He.IconicButton restore;
	[GtkChild]
	unowned Gtk.ScrolledWindow sw;
	[GtkChild]
	unowned He.EmptyPage empty_page;
	[GtkChild]
	unowned He.DisclosureButton open_file_button;

	[GtkChild]
	public unowned He.MiniContentBlock folder_mcb;
	[GtkChild]
	public unowned He.MiniContentBlock imgsize_mcb;
	[GtkChild]
	public unowned He.MiniContentBlock filesize_mcb;
	[GtkChild]
	public unowned He.MiniContentBlock filetype_mcb;
	[GtkChild]
	public unowned He.MiniContentBlock createdon_mcb;

	[GtkChild]
	public unowned Gtk.Revealer md_pane;

	public class Viewer (MainWindow? window) {
		this.window = window;
		window.render.connect (() => {
			canvas.queue_draw ();
		});
		notify["project"].connect (on_project_changed);
	}
	
	construct {
		canvas = new Canvas ();

		canvas.notify["scale"].connect (() => {
			if (canvas.scale == 0.25) {
				zoomout.sensitive = false;
			} else if (canvas.scale == 0.75) {
				zoomin.sensitive = false;
			} else {
				zoomout.sensitive = true;
				zoomin.sensitive = true;
			}
		});

		zoomin.clicked.connect (() => {
			zoom_in ();
		});
		zoomout.clicked.connect (() => {
			zoom_out ();
		});
		fullscreen.clicked.connect (() => {
			window.fullscreen ();
			window.deletable = false;
			restore.visible = true;
			fullscreen.visible = false;
		});
		restore.clicked.connect (() => {
			window.unfullscreen ();
			window.deletable = true;
			restore.visible = false;
			fullscreen.visible = true;
		});

		sw.child = canvas;

		empty_page.action_button.clicked.connect(() => {
			window.open_file ();
		});

		open_file_button.clicked.connect(() => {
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
		canvas.scale += float.parse("0.25");
	}

	public void zoom_out () {
		if (canvas.scale > 0.0) {
			canvas.scale -= float.parse("0.25");
		} else {
			canvas.scale = float.parse("0.25");
		}
	}
}

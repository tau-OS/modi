using Gtk;

public class App.View.Viewer : He.View {

	public Window.Main window { get; set; }
	public PictureFile? project {
		get { return canvas.project; }
		set { canvas.project = value; }
	}

	protected Stack stack;
	protected View.Canvas canvas;
	protected He.EmptyPage empty_state;

	public class Viewer (Window.Main window) {
		this.window = window;
		this.window.render.connect (() => {
			canvas.queue_draw ();
		});
		notify["project"].connect (on_project_changed);
	}
	
	construct {
		var builder = new Builder ();
		stack = new Stack ();
		stack.set_transition_type (StackTransitionType.CROSSFADE);
		add_css_class ("canvas");

		empty_state = new He.EmptyPage () {
			title = _("No Open Picture"),
			description = _("Open a picture to start viewing it."),
			icon = "folder-pictures-symbolic",
			button = "Open Picture"
		};

		stack.add_named (empty_state, "empty");

		canvas = new View.Canvas ();

		var scroller = new ScrolledWindow ();
		scroller.hexpand = true;
		scroller.vexpand = true;
		scroller.halign = Align.CENTER;
		scroller.valign = Align.CENTER;
		scroller.propagate_natural_height = true;
		scroller.propagate_natural_width = true;
		scroller.child = canvas;

		var overlay_button = new He.OverlayButton ("zoom-in-symbolic",null,"zoom-out-symbolic");
		overlay_button.color = He.Colors.DARK;
		overlay_button.secondary_color = He.Colors.DARK;
		overlay_button.child = scroller;
		overlay_button.clicked.connect (() => {
			zoom_in ();
		});
		overlay_button.secondary_clicked.connect (() => {
			zoom_out ();
		});

		stack.add_named (overlay_button, "canvas");

		var window_handle = new WindowHandle ();
		window_handle.hexpand = true;
		window_handle.vexpand = true;
		window_handle.set_child (stack);

		add_child (builder, window_handle, "");
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
		if (canvas.scale == float.parse("0.0")) {
			return;
		} else {
			canvas.scale -= float.parse("0.1");
		}
	}
}

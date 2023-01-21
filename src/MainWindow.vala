[GtkTemplate (ui = "/co/tauos/Modi/window.ui")]
public class Modi.MainWindow : He.ApplicationWindow {
	PictureFile? _project;

	public PictureFile? project {
		get { return this._project; }
		set {
			this._project = value;
			on_project_changed ();
		}
	}

	[GtkChild]
	unowned Gtk.Box main_box;
	[GtkChild]
	unowned He.AppBar main_bar;

	protected Viewer editor;
	public signal void render ();

	construct {
		editor = new Viewer (this);

		main_box.append (editor);

		this.show ();
	}
	
	public class MainWindow (He.Application app) {
		Object (
			application: app,
			default_width: 800,
			default_height: 600,
			width_request: 360,
			height_request: 360
		);
		
		present ();
		on_project_changed ();
	}

	void on_project_changed () {
		editor.project = project;
	}

	[GtkCallback]
	public void open_file () {
		var filter = new Gtk.FileFilter () {
			name = _("Pictures")
		};
		filter.add_pixbuf_formats ();

		var chooser = new Gtk.FileChooserNative (_("Open"), this, Gtk.FileChooserAction.OPEN, null, null);
		chooser.add_filter (filter);
		chooser.response.connect (id => {
			switch (id) {
				case -3:
					var selected_file = chooser.get_file ();
					load_project (selected_file);
					break;
			}
			chooser.unref ();
		});
		chooser.ref ();
		chooser.show ();
	}

	public void load_project (GLib.File? file) {
		new PictureFile (file).load (this);
		main_bar.add_css_class ("scrim");
		this.add_css_class ("editor-bg");
		main_bar.viewtitle_label = selected_file.get_basename ();
	}
}
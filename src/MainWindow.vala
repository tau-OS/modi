public class App.Window.Main : He.ApplicationWindow {
	PictureFile? _project;

	public PictureFile? project {
		get { return this._project; }
		set {
			this._project = value;
			on_project_changed ();
		}
	}

	protected App.View.Viewer editor;
	public signal void render ();

	construct {
		var builder = new Gtk.Builder ();
		editor = new View.Viewer (this);
		
		var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		box.append (editor);

		var header = new He.AppBar ();
		header.flat = true;

		var menu_button = new Gtk.MenuButton () {
			icon_name = "open-menu-symbolic"
		};
		menu_button.add_css_class ("flat");
		header.add_child (builder, menu_button, "view-button");

		var open_button = new Gtk.Button () {
			icon_name = "document-open-symbolic"
		};
		open_button.clicked.connect (() => {
			open_file ();
		});
		header.add_child (builder, open_button, "view-button");

		this.set_titlebar (header);
		this.set_child (box);
		this.show ();
	}
	
	public class Main (He.Application app) {
		Object (
			application: app,
			width_request: 500,
			height_request: 500
		);
		
		present ();
		on_project_changed ();
	}

	void on_project_changed () {
		editor.project = project;
	}

	public void open_file () {
		var filter = new Gtk.FileFilter () {
			name = _("Graphic Files")
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
	}
}
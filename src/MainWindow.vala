[GtkTemplate (ui = "/com/fyralabs/Modi/window.ui")]
public class Modi.MainWindow : He.ApplicationWindow {
	PictureFile? _project;

	public const string FILE_ATTRIBUTES = "standard::*,time::*,id::file,id::filesystem,etag::value";

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
	[GtkChild]
	unowned Gtk.ToggleButton props_button;

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
			width_request: 360,
			height_request: 280
		);
		
		present ();
		on_project_changed ();

        set_default_size (800, 600);
	}

	void on_project_changed () {
		editor.project = project;
	}

	[GtkCallback]
	void on_metadata_requested () {
		if (props_button.active) {
			editor.md_pane.set_reveal_child (true);
			editor.md_pane.set_visible (true);
			main_bar.remove_css_class ("scrim");
			main_bar.add_css_class ("props-scrim");
		} else {
			editor.md_pane.set_reveal_child (false);
			editor.md_pane.set_visible (false);
			main_bar.add_css_class ("scrim");
			main_bar.remove_css_class ("props-scrim");
		}
	}

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
					load_project (chooser.get_file ());
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
		main_bar.viewtitle_label = file.get_basename ();

		props_button.visible = true;

		FileInfo info = file.query_info (FILE_ATTRIBUTES, FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);

		editor.folder_mcb.subtitle = file.get_path ().replace (Environment.get_home_dir (), "~")
													 .replace ("/" + file.get_basename (), "");
		editor.filesize_mcb.subtitle = info.get_size () >= 1048576 ? (info.get_size () / 1048576).to_string ("%d MB") : (info.get_size ()).to_string ("%d B");
		editor.filetype_mcb.subtitle = info.get_content_type ().to_string ().replace("image/", "").up ();
		editor.createdon_mcb.subtitle = info.get_creation_date_time ().format ("%x %H∶%M");

		editor.imgsize_mcb.subtitle = project.source.get_intrinsic_width ().to_string () + "×" + project.source.get_intrinsic_height ().to_string () + " px";
	}
}

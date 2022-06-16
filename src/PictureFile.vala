public class Modi.PictureFile : Object {
	protected MainWindow? window { get; set; }
	public Gdk.Texture source { get; set; }
	public File file { get; set; }

	public PictureFile (File file) {
		this.file = file;
	}

	public void load (MainWindow win) {
		this.source = Gdk.Texture.from_file (file);
		this.window = win;
		window.project = this;
		notify["visible"].connect (() => {
			this.window.render ();
		});
		this.window.render ();
	}
	public void start_snapshot (Gtk.Snapshot snapshot, Graphene.Rect bounds, Canvas canvas) {
		snapshot.push_debug ("");
	}
	public void end_snapshot (Gtk.Snapshot snapshot, Graphene.Rect bounds, Canvas canvas) {
		snapshot.pop ();
	}
}
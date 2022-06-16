public class App.PictureFile : Object {
	protected Window.Main? window { get; set; }
	public Gdk.Texture source { get; set; }
	public File file { get; set; }

	public PictureFile (File file) {
		this.file = file;
	}

	public void load (Window.Main win) {
		this.source = Gdk.Texture.from_file (file);
		this.window = win;
		window.project = this;
		on_added (window);
	}
	public signal void on_added (Window.Main? win) {
		this.window = win;
		notify["visible"].connect (() => {
			this.window.render ();
		});
		this.window.render ();
	}
	public void start_snapshot (Gtk.Snapshot snapshot, Graphene.Rect bounds, App.View.Canvas canvas) {
		snapshot.push_debug ("");
	}
	public void end_snapshot (Gtk.Snapshot snapshot, Graphene.Rect bounds, App.View.Canvas canvas) {
		snapshot.pop ();
	}
}
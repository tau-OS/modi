public class Modi.Canvas : Gtk.Box {
	public PictureFile? project { get; set; }
	// 0.5 is enough default zoom for most pictures
	public float scale { get; set; default = 0.5f; }
	public int w = 0;
	public int h = 0;

	public Graphene.Rect source_rect {
		owned get {
			if (project == null) return Graphene.Rect.zero ();
			var p = project.source;
			var rect = Graphene.Rect ();
			return rect.init (0, 0, p.get_intrinsic_width (), p.get_intrinsic_height ());
		}
	}
	public Graphene.Rect target_rect {
		owned get {
			return source_rect.scale (scale, scale);
		}
	}
	public Graphene.Rect visible_rect { get; set; default = Graphene.Rect.zero (); }

	construct {
		notify["project"].connect (update_zoom);
		notify["scale"].connect (update_zoom);
		notify["visible-rect"].connect (() => queue_draw ());
	}

	void update_zoom () {
		if (scale > 0.0) {
			w = (int) (project.source.get_intrinsic_width () * scale);
			h = (int) (project.source.get_intrinsic_height () * scale);
			set_size_request (w, h);
		}
	}

	public override void snapshot (Gtk.Snapshot snapshot) {
		if (project == null) {
			base.snapshot (snapshot);
			return;
		}
		project.start_snapshot (snapshot, visible_rect, this);
		snapshot.append_texture (project.source, target_rect);
		var w = (int) (this.get_width ());
		var h = (int) (this.get_height ());

		var point = Graphene.Point ();

		snapshot.translate (point.init (
			(w / 2),
			(h / 2)
		));

		snapshot.scale (scale, scale);

		snapshot.scale(
			(project.source.get_intrinsic_width () / w),
			(project.source.get_intrinsic_height () / h)
		);
		project.end_snapshot (snapshot, visible_rect, this);
	}
}
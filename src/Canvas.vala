public class Modi.Canvas : Gtk.Box {
    public PictureFile? project { get; set; }
    public float scale { get; set; default = 1.0f; }
    public int w = 0;
    public int h = 0;

    public Graphene.Rect source_rect {
        owned get {
            if (project == null)return Graphene.Rect.zero ();
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

        set_halign (Gtk.Align.CENTER);
        set_valign (Gtk.Align.CENTER);
    }

    void update_zoom () {
        if (scale >= 0.0) {
            w = (int) (project.source.get_intrinsic_width () * scale);
            h = (int) (project.source.get_intrinsic_height () * scale);
            set_size_request (w, h);
        }
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        // The order of snapshot events here is from the end of this block, to here, the start.
        if (project == null) {
            base.snapshot (snapshot);
            return;
        }
        project.end_snapshot (snapshot, visible_rect, this);
        snapshot.append_texture (project.source, target_rect);
        var w = (int) (this.get_width ());
        var h = (int) (this.get_height ());

        var point = Graphene.Point ();

        snapshot.save ();

        snapshot.translate (point.init (
                                        (w / 2),
                                        (h / 2)
        ));

        var point2 = Graphene.Point ();

        var x = Math.fmax ((w - project.source.get_intrinsic_width ()) / 2.0, 0.0);
        var y = Math.fmax ((h - project.source.get_intrinsic_height ()) / 2.0, 0.0);

        snapshot.translate (point2.init (
                                         (float) Math.round (x),
                                         (float) Math.round (y)
        ));

        snapshot.scale (scale, scale);

        snapshot.restore ();
        project.start_snapshot (snapshot, visible_rect, this);
    }
}

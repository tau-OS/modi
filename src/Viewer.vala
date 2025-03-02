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
    unowned He.Button zoomout;
    [GtkChild]
    unowned He.Button zoomin;
    [GtkChild]
    unowned He.Button back;
    [GtkChild]
    unowned He.Button forward;
    [GtkChild]
    unowned He.Button fullscreen;
    [GtkChild]
    unowned He.Button restore;
    [GtkChild]
    unowned Gtk.ScrolledWindow sw;
    [GtkChild]
    unowned He.EmptyPage empty_page;
    [GtkChild]
    unowned He.Button open_file_button;

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
            } else if (canvas.scale == 2.0) {
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
        back.clicked.connect (() => {
            load_previous_image ();
        });
        forward.clicked.connect (() => {
            load_next_image ();
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

        empty_page.action_button.clicked.connect (() => {
            window.open_file ();
        });

        open_file_button.clicked.connect (() => {
            window.open_file ();
        });
    }

    void on_project_changed () {
        var is_empty = (project == null);

        stack.visible_child_name = is_empty ? "empty" : "canvas";

        window.set_default_size (canvas.w, canvas.h);

        if (is_empty)
            this.remove_css_class ("editor-bg");
        else
            this.add_css_class ("editor-bg");
    }

    public void zoom_in () {
        canvas.scale += float.parse ("0.25");
    }

    public void zoom_out () {
        if (canvas.scale >= 0.0) {
            canvas.scale -= float.parse ("0.25");
        } else {
            canvas.scale = float.parse ("0.25");
        }
    }

    private void load_previous_image () {
        if (project == null || project.file == null)
            return;

        var current_path = project.file.get_path ();
        var parent_folder = project.file.get_parent ();

        try {
            var enumerator = parent_folder.enumerate_children (
                                                               "standard::*",
                                                               FileQueryInfoFlags.NONE
            );

            var files = new Gee.ArrayList<File> ();
            FileInfo info = null;

            while ((info = enumerator.next_file ()) != null) {
                var file = parent_folder.get_child (info.get_name ());
                var content_type = info.get_content_type ();

                if (content_type != null && content_type.has_prefix ("image/")) {
                    files.add (file);
                }
            }

            files.sort ((a, b) => {
                return a.get_basename ().collate (b.get_basename ());
            });

            int current_index = -1;
            for (int i = 0; i < files.size; i++) {
                if (files[i].get_path () == current_path) {
                    current_index = i;
                    break;
                }
            }

            if (current_index > 0) {
                load_file (files[current_index - 1]);
            }
        } catch (Error e) {
            warning ("Error navigating images: %s", e.message);
        }
    }

    private void load_next_image () {
        if (project == null || project.file == null)
            return;

        var current_path = project.file.get_path ();
        var parent_folder = project.file.get_parent ();

        try {
            var enumerator = parent_folder.enumerate_children (
                                                               "standard::*",
                                                               FileQueryInfoFlags.NONE
            );

            var files = new Gee.ArrayList<File> ();
            FileInfo info = null;

            while ((info = enumerator.next_file ()) != null) {
                var file = parent_folder.get_child (info.get_name ());
                var content_type = info.get_content_type ();

                if (content_type != null && content_type.has_prefix ("image/")) {
                    files.add (file);
                }
            }

            files.sort ((a, b) => {
                return a.get_basename ().collate (b.get_basename ());
            });

            int current_index = -1;
            for (int i = 0; i < files.size; i++) {
                if (files[i].get_path () == current_path) {
                    current_index = i;
                    break;
                }
            }

            if (current_index >= 0 && current_index < files.size - 1) {
                load_file (files[current_index + 1]);
            }
        } catch (Error e) {
            warning ("Error navigating images: %s", e.message);
        }
    }

    private void load_file (File file) {
        try {
            window.load_project (file);
        } catch (Error e) {
            warning ("Error loading image: %s", e.message);
        }
    }
}

icons_dir = join_paths(get_option('datadir'), 'icons', 'hicolor')
scalable_dir = join_paths(icons_dir, 'scalable', 'apps')
symbolic_dir = join_paths(icons_dir, 'symbolic', 'apps')

install_data(
    join_paths('icons', 'color.svg'),
    install_dir: scalable_dir,
    rename: meson.project_name() + '.svg'
)
install_data(
    join_paths('icons', 'symbolic.svg'),
    install_dir: symbolic_dir,
    rename: meson.project_name() + '-symbolic.svg'
)

i18n.merge_file(
    input: 'desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: join_paths(meson.source_root(), 'po'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'applications')
)

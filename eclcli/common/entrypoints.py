"""Entry point helpers without importing deprecated pkg_resources."""

from importlib import metadata


class UnknownExtra(Exception):
    pass


def iter_entry_points(group, name=None):
    eps = metadata.entry_points()
    if hasattr(eps, 'select'):
        selected = eps.select(group=group)
        if name is not None:
            selected = selected.select(name=name)
        return selected

    selected = eps.get(group, [])
    if name is not None:
        selected = [ep for ep in selected if ep.name == name]
    return selected

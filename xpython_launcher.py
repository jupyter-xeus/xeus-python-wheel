if __name__ == '__main__':
    def _xpython_get_connection_filename():
        import argparse
        parser = argparse.ArgumentParser()
        parser.add_argument('-f', help='Jupyter kernel connection filename')
        args, unknown = parser.parse_known_args()
        return args.f

    from xpython import launch as _xpython_launch
    _xpython_launch(_xpython_get_connection_filename() or '')

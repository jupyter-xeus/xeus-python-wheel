if __name__ == '__main__':
    def _get_connection_filename():
        import argparse
        parser = argparse.ArgumentParser()
        parser.add_argument('-f', help='Jupyter kernel connection filename')
        args = parser.parse_args()
        return args.f
    filename = _get_connection_filename() or ''
    from xpython import launch
    launch(filename)
    

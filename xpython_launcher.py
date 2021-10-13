if __name__ == '__main__':
    import sys
    from xpython import launch as _xpython_launch
    args_list = sys.argv[:]
    sys.argv = sys.argv[:1]  # Remove unnecessary arguments
    _xpython_launch(args_list)

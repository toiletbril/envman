## envman

skeleton of a nix alternative written in bash, because I hate switching distros
and systemd.

### usage

```
envman <environment> [variation]
```

when using non-relative paths as the first argument, envman searches `env/`
directory located in the same directory as the envman itself.

if the first argument is a file or a directory that actually exists, envman
will try to use it instead.

envman launches an instance of bash shell and sources an environment file
that's been given to it. all to put your chad stat up to a test whether you can
describe your developer environments entirely in bash without some """immutable
and reproducible""" bullshit for pussies. that's it.

well, actually, there is some qol, as described down below.

#### examples

this is your environment folder:
```
some-env
complex-env/
├── default
└── other
```

to enter `some-env`:
```bash
$ cat some-env
ABOBA=1
$ envman some-env
--- entering special environment! ---
(some-env) $ echo $ABOBA
1
...
```

if an environment is a directory, it's referred to as complex environment.
files inside referred to as it's variations. by default, `default` variation
is launched for that environment.

to enter `complex-env/default`:
```bash
$ envman complex-env
--- entering special environment! ---
(complex-env/default) $
...
```

to enter `other`:
```bash
$ envman complex-env other
--- entering special environment! ---
(complex-env/other) $
...
```

envman can be used in a shebang as `#!/bin/env envman` if it's added in `PATH`:
```bash
$ cat some-env
#!/bin/env envman
ABOBA=1
$ ./some-env
--- entering special environment! ---
(./some-env) $ echo $ABOBA
1
...
```

### environments included

- `gpdb` creates and then reuses a docker container with various Greenplum
  variants.

  it requires Greenplum source tree available locally on the host machine. take
  a look inside the whole environment to get a gist of how it works.

- `personal` is just personal stuff that does not really belong to dotfiles.

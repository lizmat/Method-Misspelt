[![Actions Status](https://github.com/lizmat/Method-Misspelt/actions/workflows/linux.yml/badge.svg)](https://github.com/lizmat/Method-Misspelt/actions) [![Actions Status](https://github.com/lizmat/Method-Misspelt/actions/workflows/macos.yml/badge.svg)](https://github.com/lizmat/Method-Misspelt/actions) [![Actions Status](https://github.com/lizmat/Method-Misspelt/actions/workflows/windows.yml/badge.svg)](https://github.com/lizmat/Method-Misspelt/actions)

NAME
====

Method::Misspelt - allow for misspelled method calls

SYNOPSIS
========

```raku
use Method::Misspelt;
class Foo does Method::Misspelt {
    method foo-bar() { "foobar" }
}
say Foo.foo_bar;  # foobar

class Bar does Method::Misspelt[:mangler(*.lc)] {
    method foo-baz() { "foobaz" }
}
say Bar.FOO-baz;  # foobaz

say Bar.misspelt;  # Map.new((FOO-baz => foo-baz))
```

DESCRIPTION
===========

The `Method::Misspelt` distribution provides a `Method::Misspelt` role that allows a class to efficiently allow for non-existing methods being called that could be considered a misspelling of another method in that class.

It is only partly serious: it serves mostly as an example of what is possible with a [`FALLBACK` method](https://docs.raku.org/language/typesystem#Fallback_method) in a class.

METHODS
=======

FALLBACK
--------

The `Method::Misspelt` role provides a `FALLBACK` method. If your class provides its own `FALLBACK` method, then the one from the role will be ignored.

misspelt
--------

The `misspelt` method returns a `Map` with the mapping of the misspelt method name and the name of the method that was actually called.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Method-Misspelt Comments and Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2026 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.


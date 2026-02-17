# These global variables will contain the "class" attributes if you will
# for the class that ingests this role, so that all lookups are shared
# between instantiations of the consuming class.  Note that the LOOKUP
# hash is to handle the cases where a call is made on a callsite that
# previously caused FALLBACK handling: the dispatch logic enshrined
# the FALLBACK method as the method to be called, so it will never see
# the method that was added to the metamodel *at that callsite*.
my %LOOKUP;
my %MANGLED;
my %END;
my $lock := Lock.new;

role Method::Misspelt[
  :&mangler = *.trans("_" => "-"),
  :$END     = True
] {

    # Create role local acceses to global data structures.  This code
    # is run when the role is being ingested into the class.  It thus
    # provides an environment for each class that ingests this role.
    my $class := $?CLASS.^name;
    my %lookup;
    my %mangled;

    # Because it *is* technically possible (although highly unlikely)
    # that multiple threads are composing this role at the same time,
    # we make sure that updates to the global hashes is done by one
    # thread at a time.
    $lock.protect: {
        %lookup      := %LOOKUP{ $class} := %();
        %mangled     := %MANGLED{$class} := %();
        %END{$class} := True if $END;
    }

    method misspelt(--> Map:D) { %mangled.Map }

    method FALLBACK($name, |c) is hidden-from-backtrace {
        my $mangled := mangler($name);

        # Check the lookup hash first to handle enshrined call sites
        if %lookup{$mangled} -> &code {
            code(self, |c)
        }

        # Ask the metamodel for method by the mangled name, making sure
        # we don't get the fallback method (otherwise we'd infiniloop)
        elsif self.^find_method($mangled, :no_fallback) -> &code {

            # To make this more or less thread-safe, we need to make sure
            # this thread is the only one making changes.  The reason a
            # "try" is done on the add_method call, is that it *is*
            # technically possible for another thread to have snuck in
            # the mangled method name: trying to add the same method
            # name would result in an execution error, so prevent that
            # from happening.  This is not so important for the lookup
            # hash, as for that it would just be a little bit of extra
            # work
            $lock.protect: {

                # Inform the metamodel object of the new method
                try self.^add_method($name, &code);

                # Add it to the lookup for enshrined call sites
                my %new-lookup := %lookup.clone;
                %new-lookup{$mangled} := &code;
                %lookup := %LOOKUP{$class} := %new-lookup;

                # Keep statistics
                my %new-mangled := %mangled.clone;
                %new-mangled{$name} := $mangled;  # UNCOVERABLE
                %mangled := %MANGLED{$class} := %new-mangled;
            }
            code(self,|c)
        }

        # Alas, not cached and not found, so throw an error
        else {
            X::Method::NotFound.new(
              :invocant(self), :method($name), :typename(self.^name)
            ).throw;
        }
    }
}

# Misspelled calls reporting only for classes that want them
END {
    for %END.keys.sort -> $class {
        if %MANGLED{$class} -> %mangled {
            note "Found %mangled.elems() misspelt call(s) on $class:";
            note "  $_.key() -> $_.value()" for %mangled;
        }
    }
}

# vim: expandtab shiftwidth=4

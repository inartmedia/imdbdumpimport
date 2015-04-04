This project imports the IMDB database dump (available at [ftp://ftp.fu-berlin.de/pub/misc/movies/database/](ftp://ftp.fu-berlin.de/pub/misc/movies/database/)) into a relational database.
It currently supports import of only (movies,actors,actresses,languages,genres and ratings data). The plan is to extend the functionality to the entire database dump.

The parser is (being) written in Perl and imports into a mysql database, but allows the user to plugin additional serialization options.


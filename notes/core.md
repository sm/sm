# SM Framework Core Development Notes/Rules

SM Framework Core must:

  Never rely on functions which contain argument parsing (example: public api)

  Validate only input which does not come from within the core system

  Only call internal functions ( _\_sm... )

  Use shell primitives everywhere possible unless very good reasons not to are
  stated in comments around where it is not done.

  Make a strong effort to minimize function calls for increased speed, but not
  at the cost of code readability (from a seasoned shell scripters POV ;) )


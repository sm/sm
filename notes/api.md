# SM Framework Core Development Notes/Rules

SM Framework Core APIs must:

  Validate every possible input combination

  Check for every possible 'programmer error' and issue a fail if found

  Provide a single entry point for each 'concept', with a well thought out DSL

  Keep public api functions in the api/shell/{api name} modules path

  Keep internal functions in the internal/shell/{api name} modules path

  Use shell primitives for all 'base' api's

  Use 'base' api's for writing complex api's (ex: package,service,databae)


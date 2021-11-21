# Equatable By Reflection

An experimental global function that allows two Swift 'Any' values to be compared for value equality. 

Values are compared by recursively traversing their properties and subproperties, using reflection offered by the Mirror class, as well as String(describing:)

If all property values match, they are considered equal, even if the class instances are not identical (i.e., !==)

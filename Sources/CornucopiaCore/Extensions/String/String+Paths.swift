//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension String {

    /// Returns the basename, if interpreting the contents as a pathname
    var CC_basename: String {
        //FIXME: This is a rather slow implementation… better scan from the right, find the first '/', and then return what we have got
        let components = self.split(separator: "/")
        return components.isEmpty ? "" : String(components.last!)
    }
}

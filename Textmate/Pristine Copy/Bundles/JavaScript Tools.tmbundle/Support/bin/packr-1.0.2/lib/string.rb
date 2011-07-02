class String
  def rescape
    gsub(/([\/()\[\]{}|*+-.,^$?\\])/, "\\\\1")
  end
end

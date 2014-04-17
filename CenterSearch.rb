# Defines a module to allow searching for an object from the center of an
# ImageMagick View
module CenterSearch

  # Searches for a target in an array beginning from the center and
  # progressively spanning outward. Only searches the largest inscribed
  # square centered in the array. Only works on even dimensioned arrays.
  # Throws back first occurrence of target pixel color.
  def search_2D(view, columns, rows, target)
    # Size of "square" to search is the smaller of the dimensions of the
    # array.
    if columns <= rows
      size = columns / 2 - 1
    else
      size = rows / 2 - 1
    end

    # "Center" refers to NW corner of center.
    centerx = columns / 2 - 1
    centery = rows / 2 - 1

    # Clean method of breaking out of loop upon finding a match
    catch(:return) do
      # Search the array.
      0.upto(size) do |i|
        # Search top row of search area
        temp1 = 0
        view[centery-i][(centerx-i)..(centerx+1+i)].each do |pixel|
          throw(:return, ["Found in top row", [centerx-i+temp1, centery-i]]) if (pixel <=> target) == 0
          temp1 = temp1 + 1
        end
      
        # Search bottom row of search area
        temp2 = 0
        view[centery+1+i][(centerx-i)..(centerx+1+i)].each do |pixel|
          throw(:return, ["Found in bottom row", [centerx-i+temp2, centery+1-i]]) if (pixel <=> target) == 0
          temp2 = temp2 + 1
        end
      
        #Search left column of search area
        temp3 = 0
        view[(centery+1-i)..(centery+i)][centerx-i].each do |pixel|
          throw(:return, ["Found in left column", [centerx-i, centery+1-i+temp3]]) if (pixel <=> target) == 0
          temp3 = temp3 + 1
        end
      
        #Search right column of search area
        temp4 = 0
        view[(centery+1-i)..(centery+i)][centerx+1+i].each do |pixel|
          throw(:return, ["Found in right column", [centerx+1+i, centery+1-i+temp4]]) if (pixel <=> target) == 0
          temp4 = temp4 + 1
        end      
      end
      return nil
    end
    
  end
  module_function :search_2D
end

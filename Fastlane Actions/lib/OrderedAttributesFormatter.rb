#!/usr/bin/env ruby

class OrderedAttributesFormatter < REXML::Formatters::Default
  def write_element(node, output)
    if node.expanded_name == 'xliff'
      write_xliff_element(node, output)
    else
      super(node, output)
    end
  end

  # override so we can sort xliff node attributes like weblate
  def write_xliff_element(node, output)
    output << "<#{node.expanded_name}"

    weblate_order = ['xmlns', 'xsi', 'schemaLocation', 'version']

    node.attributes.to_a.map { |a|
      Hash === a ? a.values : a
    }.flatten.sort_by {|attr| weblate_order.index(attr.name) }.each do |attr|
      output << " "
      attr.write( output )
    end unless node.attributes.empty?

    if node.children.empty?
      output << "/"
    else
      output << ">"
      node.children.each { |child|
        write( child, output )
      }
      output << "</#{node.expanded_name}"
    end
    output << ">"
  end
end

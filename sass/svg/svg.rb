module SvgFunctions
    def svg_convert(width, svgIn, pngOut, pngOut2x, dir1x, dir2x)
        assert_type width, :Number
        assert_type svgIn, :String
        assert_type pngOut, :String
        assert_type pngOut2x, :String
        assert_type dir1x, :String
        assert_type dir2x, :String

        svgPath = File.join Compass.configuration.images_path, svgIn.value
        pngPath = File.join Compass.configuration.images_path, dir1x.value, pngOut.value + ".png"
        pngPath2x = File.join Compass.configuration.images_path, dir2x.value, pngOut2x.value + ".png"

        width2x = width.to_i * 2

        ret = 1

        begin
            if !File.exists? svgPath
                Compass::Logger.new.record :error, svgPath
                raise "SVG does not exist"
            end

            if File.exists? pngPath
                Compass::Logger.new.record :identical, pngPath
                Compass::Logger.new.record :identical, pngPath2x
                ret = 0
            else
                Compass::Logger.new.record :create, pngPath
                Compass::Logger.new.record :create, pngPath2x
                Compass::Logger.new.record :warning, "We have generated a new PNG, your sprite-map will be out of date and will be updated on next compile."
                system(
                    "rsvg-convert",         # Process
                    "-a",
                    "-w", width.to_s,       # Width
                    "#{svgPath}",           # Input
                    "-o", "#{pngPath}"      # Output
                )

                system(
                    "rsvg-convert",         # Process
                    "-a",
                    "-w", width2x.to_s,     # Width
                    "#{svgPath}",           # Input
                    "-o", "#{pngPath2x}"    # Output
                )
            end

            Sass::Script::Number.new ret

        rescue
            Sass::Script::Number.new 0
        end
    end

    def svg_check_png(pngIn, dir1x, dir2x)
        assert_type pngIn, :String
        assert_type dir1x, :String
        assert_type dir2x, :String

        png1xPath = File.join Compass.configuration.images_path, dir1x.value, pngIn.value + ".png"
        png2xPath = File.join Compass.configuration.images_path, dir2x.value, pngIn.value + ".png"

        begin
            if File.exists? png1xPath
                ##Compass::Logger.new.record :exists, png1xPath + " exists, lets sprite it!"
                Sass::Script::Number.new 1
            end
            if File.exists? png2xPath
                ##Compass::Logger.new.record :exists, png2xPath + " exists, lets sprite it!"
                Sass::Script::Number.new 1
            end
        rescue
            Compass::Logger.new.record :error, pngIn.value + ".png doesn't exist, try again!"
            Sass::Script::Number.new 1
        end
    end

    def svg_height(svgIn, width)
        assert_type svgIn, :String
        svgPath = File.join Compass.configuration.images_path, svgIn.value
        require 'rexml/document'
        svg = File.read(svgPath)
        doc = REXML::Document.new(svg)

        w = doc.root.attributes['width'].to_i
        h = doc.root.attributes['height'].to_i

        r = (h.to_i / w.to_i * width.to_i);

        Sass::Script::Number.new r
    end

end

module Sass::Script::Functions
  include SvgFunctions
end
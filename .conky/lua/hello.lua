require 'cairo'
function conky_startlua()
   if conky_window == nil then return end
   local cs = cairo_xlib_surface_create(conky_window.display,conky_window.drawable, conky_window.visual, conky_window.width,conky_window.height)
   cr = cairo_create(cs)
   cairo_select_font_face (cr, 'Ubuntu', 0, 0)
   cairo_set_font_size (cr, 20)
   cairo_set_source_rgba (cr, 1, 1, 1, 1)
   cairo_move_to (cr, 20, 20)
   cairo_show_text(cr, 'Hello, World!')
   cairo_destroy(cr)
end

local enable = gui.add_checkbox("Anti Reportbot")

function on_gameevent(e)
  if e:get_name() == "cs_win_panel_match" and tostring(enable:get_value()) == "true" then
    engine.client_cmd("disconnect")
  end
end

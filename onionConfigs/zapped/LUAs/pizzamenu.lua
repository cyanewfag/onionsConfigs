http.download("https://i.imgur.com/3ZTXkLM.png", "C://zapped//lua//pizza.png")

if (filesystem.file_exists("C://zapped//lua//pizza.png")) then
    local pizzaTexture = renderer.create_texture("C://zapped//lua//pizza.png");

    function on_render()
        local screenSize = engine.screen_size();
        renderer.image(pizzaTexture, screenSize.x / 4, screenSize.y / 4, screenSize.x / 4 * 3, screenSize.y / 4 * 3, 180, color.new(255, 255, 255, 255));
    end
end
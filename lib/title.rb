class Title < State
    @@choice = 0
    def initialize game
        @game = game
        @screen = game.screen
        @queue = game.queue
        
        @title_text = Text.new 0, 35, "Pong", 100
        @play_text = Text.new 0, 200, "Jugar", 50
        @options_text = Text.new 0, 265, "Opciones", 50
        @about_text = Text.new 0, 330, "Acerca del juego", 50
        @quit_text = Text.new 0, 395, "Salir", 50
        @title_text.center_x @screen.width
        @menu = [@play_text, @options_text, @about_text, @quit_text]
        @menu.each { |text| text.center_x @screen.width}
        @line = GameObject.new(0, 150, Rubygame::Surface.new([@screen.width,10]).fill([255,255,255]))
        
        @select = Selector.new @@choice, *@menu
    end

    def update
        @select.update 
        @queue.each do |ev|
            @select.handle_event ev
            case ev
                when Rubygame::KeyDownEvent
                    if ev.key == Rubygame::K_RETURN
                        @@choice = @select.choice
                        case @select.choice
                            when 0
                                @game.switch_state(InGame.new(@game))
                            when 1
                                @game.switch_state(Options.new(@game))
                            when 2
                                @game.switch_state(About.new(@game))
                            when 3
                                Rubygame.quit
                                exit
                        end
                    end
            end
        end
    end

    def draw
        @screen.fill [0, 0, 0]

        [@select, @title_text, *@menu, @line].each { |text| text.draw @screen }

        @screen.flip
    end
end
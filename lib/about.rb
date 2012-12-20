class About < State
    def initialize game
        @game = game
        @screen = game.screen
        @queue = game.queue
        
        @pong = Text.new 0, 35, "Pong", 100
        @line = GameObject.new(0, 150, Rubygame::Surface.new([@screen.width,10]).fill([255,255,255]))
        @created_by = Text.new 0, 200, "Juego desarrollado por", 45
        @created_by2 = Text.new 0, 250, "Rodrigo C. Diez", 45
        @for_the = Text.new 0, 300, "A partir del tutorial", 45
        @for_the2 = Text.new 0, 350, "Making Games with Ruby", 45
        @on = Text.new 0, 400, "de Man With Code", 45
        @website = Text.new 0, 450, "http://manwithcode.com", 45
        [@created_by, @created_by2, @for_the, @for_the2, @on, @website, @pong, @line].each { |text| text.center_x @screen.width }
    end
    
    def update
        @queue.each do |ev|
            case ev
                when Rubygame::KeyDownEvent
                if ev.key == Rubygame::K_ESCAPE
                    @game.switch_state Title.new(@game)
                end
            end
        end
    end

    def draw
        @screen.fill [0, 0, 0]

        [@pong, @line, @created_by, @created_by2, @for_the, @for_the2, @on, @website].each { |text| text.draw @screen }

        @screen.flip
    end
end

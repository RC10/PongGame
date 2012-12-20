class Options < State
    def initialize game
        @game = game
        @screen = game.screen
        @queue = game.queue

        @pong = Text.new 0, 35, "Opciones", 100
        @line = GameObject.new(0, 150, Rubygame::Surface.new([@screen.width,10]).fill([255,255,255]))

        @winning_score = List.new 0, 200, 48, "Puntuacion para ganar: ", :winning_score, [-1,3,5,7,9]
        @ball_speed = List.new 0, 250, 48, "Velocidad de la bola: ", :ball_speed, [3,4,5,6,7,8,9,10]
        @music = OnOff.new 0, 300, 48, "Musica: ", :music
        @fx = OnOff.new 0, 350, 48, "Sonido: ", :fx
        @reset = Reset.new 0, 400, 48
        
        @options = [@winning_score, @ball_speed, @music, @fx, @reset]
        @reset.options = @options
        @select = Selector.new 0, *@options
        
        @objs = [@pong, @line, *@options]
        @objs.each { |obj| obj.center_x @screen.width }
        @objs += [@select]
    end
    
    def update
        @select.update
        @queue.each do |ev|
            @select.handle_event ev
            case ev
                when Rubygame::KeyDownEvent
                    if ev.key == Rubygame::K_ESCAPE
                        @game.switch_state Title.new(@game)
                    end
                    if ev.key == Rubygame::K_RETURN
                        @options[@select.choice].cycle
                    end
            end
        end
    end

    def draw
        @screen.fill [0, 0, 0]
        @objs.each { |obj| obj.draw @screen }
        @screen.flip
    end
end

#Encender/apagar la musica y el sonido de la bola
class OnOff < Text
    def initialize x, y, size, prefix, value
        @value = value
        @prefix = prefix
        super x, y, gen_text, size
    end
    
    def cycle
        Conf[@value] = !Conf[@value]
        self.text = gen_text
        Conf.save
    end
    
    def gen_text
        if Conf[@value] == true
            return @prefix + "On"
        else
            return @prefix + "Off"
        end
    end
    
    def reset
        self.text = gen_text
    end
end

#Lista de opciones para el marcador y la velocidad
class List < Text
    def initialize x, y, size, prefix, value, choices
        @prefix = prefix
        @value = value
        @choices = choices
        @choice = @choices.index(Conf[@value])
        super x, y, gen_text, size
    end
    
    def cycle
        @choice += 1
        @choice = 0 if @choices[@choice] == nil
        Conf[@value] = @choices[@choice]
        self.text = gen_text
        Conf.save
    end
    
    def gen_text
        return @prefix + Conf[@value].to_s
    end
    
    def reset
        @choice = @choices.index(Conf[@value])
        self.text = gen_text
    end
end

#Volver a las opciones por defecto
class Reset < Text
    attr_writer :options
    def initialize x, y, size
        super x, y, "Resetear", size
    end
    
    def cycle
        Conf.Reset
        Conf.save
        @options.each do |opt|
            opt.reset
        end
    end
    
    def reset
    end
end
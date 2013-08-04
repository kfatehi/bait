require 'ffi-ncurses'
require 'ffi-ncurses/mouse'

module Bait
  module GUI
    extend FFI::NCurses
    class << self
      def setup_screen &block
        initscr
        start_color
        curs_set 0
        raw
        noecho
        keypad stdscr, true
        begin
          block.call(self)
        ensure
          endwin
        end
      end

      def init!
        setup_screen do
          move 10, 10
          init_pair(1, COLOR_BLACK, COLOR_RED)
          attr_set A_NORMAL, 1, nil
          addch("A"[0].ord)
          standout
          addstr "More"



          # Get all the mouse events
          mousemask(ALL_MOUSE_EVENTS | REPORT_MOUSE_POSITION, nil)
          mouse_event = MEVENT.new
          ch = 0
          addstr "Click mouse buttons anywhere on the screen. q to quit\n"
          until ch == "q"[0].ord do
            ch = getch
            case ch
            when KEY_MOUSE
              if getmouse(mouse_event) == OK
                if FFI::NCurses::BUTTON_CLICK(mouse_event[:bstate], 1) > 0
                  addstr "Button 1 pressed (%d, %d, %x)" % [mouse_event[:y], mouse_event[:x], mouse_event[:bstate]]
                elsif FFI::NCurses::BUTTON_CLICK(mouse_event[:bstate], 2) > 0
                  addstr "Button 2 pressed (%d, %d, %x)" % [mouse_event[:y], mouse_event[:x], mouse_event[:bstate]]
                elsif FFI::NCurses::BUTTON_CLICK(mouse_event[:bstate], 3) > 0
                  addstr "Button 3 pressed (%d, %d, %x)" % [mouse_event[:y], mouse_event[:x], mouse_event[:bstate]]
                else
                  addstr "Other mouse event %x" % mouse_event[:bstate]
                end
                row = getcury(stdscr) + 1
                move row, 0
                move mouse_event[:y], mouse_event[:x]
                addch " "[0].ord | WA_STANDOUT
                move row, 0
              end
            else
              printw "other event (%lu)", :ulong, ch
              addstr "\n"
            end
            refresh
          end








          getch
        end
      end
    end
  end
end

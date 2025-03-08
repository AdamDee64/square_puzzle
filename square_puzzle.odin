package square_puzzle

import "core:fmt"
import rand "core:math/rand"
import rl "vendor:raylib"

WIDTH :: 800
HEIGHT :: 600
Title : cstring = "square puzzle thing"

FPS :: 60

CELL_SIZE :: 45
GRID_X :: 10
GRID_Y :: 10

MAX_X :: (GRID_X + 1) >> 1
MAX_Y :: (GRID_Y + 1) >> 1

LEFT_SPACE :: (WIDTH - GRID_X * CELL_SIZE) / 2 + 50
TOP_SPACE :: (HEIGHT - GRID_Y * CELL_SIZE) / 2 + 50

COLORS := [?]rl.Color {
    rl.RAYWHITE,
    rl.LIGHTGRAY,
    rl.SKYBLUE,
    rl.BLUE,
    rl.RED,
}

main :: proc() {

    show_back := false

    rl.InitWindow(WIDTH, HEIGHT, Title)
    rl.SetTargetFPS(FPS)

    back_grid := [GRID_X * GRID_Y]u8 {}
    front_grid := [GRID_X * GRID_Y]u8 {}

    randomize_grid(&back_grid)
    total_count := grid_count(back_grid) // use this for "unlocking" maybe tiles 

    back_col_count := [MAX_Y * GRID_X]u8 {}
    back_row_count := [MAX_X * GRID_Y]u8 {}

    front_col_count := [MAX_Y * GRID_X]u8 {}
    front_row_count := [MAX_X * GRID_Y]u8 {}

    count_columns(back_grid, &back_col_count)
    count_rows(back_grid, &back_row_count)

    for !rl.WindowShouldClose() {

        if rl.IsMouseButtonPressed(.LEFT) {
            x, y := mark_cell(3, &front_grid)
            if x >= 0 {
                if back_grid[y * GRID_X + x] != 3 {
                    front_grid[y * GRID_X + x] = 4
                }
            }
            count_columns(front_grid, &front_col_count)
            count_rows(front_grid, &front_row_count)
        }
        if rl.IsMouseButtonPressed(.RIGHT) {
            mark_cell(1, &front_grid)
            
        }
        if rl.IsKeyPressed(.B) {
            show_back = !show_back
        }
        if rl.IsKeyPressed(.C) {
            clear_grid(&front_grid)
        }

        if rl.IsKeyPressed(.R) {
            clear_grid(&front_grid)
            clear_grid(&back_grid)
            show_back := false
            randomize_grid(&back_grid)
            count_columns(back_grid, &back_col_count)
            count_rows(back_grid, &back_row_count)
        }

        rl.BeginDrawing()

        rl.ClearBackground(rl.BLACK)

        if show_back {
            draw_grid(back_grid)
        } else {
            draw_grid(front_grid)
        }
        
        draw_col_count(back_col_count)
        draw_row_count(back_row_count)

        rl.EndDrawing()
    }
    rl.CloseWindow()
}

mark_cell :: proc(mark : i32, grid : ^[GRID_X * GRID_Y]u8 ) -> (i32, i32) {
    mouse_x := (rl.GetMouseX() - LEFT_SPACE) 
    mouse_y := (rl.GetMouseY() - TOP_SPACE)

    if mouse_x < 0 || mouse_y < 0 {
        return -1, -1
    }

    mouse_x /= CELL_SIZE
    mouse_y /= CELL_SIZE
    
    if mouse_x >= 0 && mouse_x < GRID_X && mouse_y >= 0 && mouse_y < GRID_Y {
        if mark == 3 {
            grid[mouse_y * GRID_X + mouse_x] = 3
        } else if grid[mouse_y * GRID_X + mouse_x] != 3{
            grid[mouse_y * GRID_X + mouse_x] += 1
            grid[mouse_y * GRID_X + mouse_x] %= 3
        }
        return mouse_x, mouse_y
    }
    return -1, -1
}

randomize_grid :: proc(grid : ^[GRID_X * GRID_Y]u8) {
    for &cell in grid {
        cell = rand.float32() < 0.5 ? 0 : 3
    }

}

draw_grid :: proc(grid : [GRID_X * GRID_Y]u8) {
    for cell, i in grid {
        rl.DrawRectangle(
            LEFT_SPACE + i32(i) % GRID_X * CELL_SIZE,
            TOP_SPACE + i32(i) / GRID_X * CELL_SIZE,
            CELL_SIZE, 
            CELL_SIZE,
            COLORS[cell]
        )
    }

    grid_color := rl.DARKPURPLE

    x1 : i32 = LEFT_SPACE
    x2 : i32 = LEFT_SPACE
    y1 : i32 = TOP_SPACE
    y2 : i32 = TOP_SPACE + GRID_Y * CELL_SIZE

    for i in 0..=GRID_X{
        rl.DrawLine(x1, y1, x2, y2, grid_color)
        x1 += CELL_SIZE
        x2 += CELL_SIZE
    }

    x1 = LEFT_SPACE
    x2 = LEFT_SPACE + GRID_X * CELL_SIZE
    y1 = TOP_SPACE
    y2 = TOP_SPACE

    for i in 0..=GRID_Y{
        rl.DrawLine(x1, y1, x2, y2, grid_color)
        y1 += CELL_SIZE
        y2 += CELL_SIZE
    }
}

grid_count :: proc(grid : [GRID_X * GRID_Y]u8) -> i32 {
    count : i32 = 0
    for cell in grid {
        if cell == 3 {
            count += 1
        }
    }
    return count
}

clear_grid :: proc(grid : ^[GRID_X * GRID_Y]u8) {
    for &cell in grid {
        cell = 0
    }
}

count_columns :: proc(grid : [GRID_X * GRID_Y]u8, col_box : ^[MAX_Y * GRID_X]u8) {
    for i in 0..<GRID_X {
        cell := i * MAX_Y
        for x in 0..<MAX_Y {
            col_box[cell + x] = 0
        }
        for j in 0..<GRID_Y {
            if grid[j * GRID_X + i] == 3{
                col_box[cell] += 1
                continue
            } 
            if col_box[cell] != 0{
                cell += 1
            }
        }
    }
}

count_rows :: proc(grid : [GRID_X * GRID_Y]u8, row_box : ^[MAX_X * GRID_Y]u8) {
    for i in 0..<GRID_Y {
        cell := i * MAX_X
        for x in 0..<MAX_X {
            row_box[cell + x] = 0
        }
        for j in 0..<GRID_X {
            if grid[i * GRID_X + j] == 3{
                row_box[cell] += 1
                continue
            } 
            if row_box[cell] != 0{
                cell += 1
            }
        }
    }
}

draw_col_count :: proc(col_count : [MAX_Y * GRID_X]u8) {
    for i in 0..<GRID_X {
        p := MAX_Y * i + MAX_Y - 1
        cell : i32 = 0
        for j in 0..<MAX_Y {
            if col_count[p - j] != 0 {
                rl.DrawText(fmt.ctprintf("%d", col_count[p - j]), LEFT_SPACE + 15 + i32(i) * CELL_SIZE, (TOP_SPACE - 20) - cell * 20, 15, rl.RAYWHITE)
                cell += 1
            }
        }
    }
}

draw_row_count :: proc(row_count : [MAX_X * GRID_Y]u8) {
    for i in 0..<GRID_Y {
        p := MAX_X * i + MAX_X - 1
        cell : i32 = 0
        for j in 0..<MAX_X {
            if row_count[p - j] != 0 {
                rl.DrawText(fmt.ctprintf("%d", row_count[p - j]), LEFT_SPACE - 15 - (cell * 35), TOP_SPACE + 20 + (CELL_SIZE * i32(i)), 15, rl.RAYWHITE)
                cell += 1
            }
        }
    }
}

check_column :: proc(x : i32) {

}

check_row :: proc(y : i32) {

}
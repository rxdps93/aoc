#include <stdio.h>
#include <stdlib.h>
#include "queuecumber.h"

#define TEST 0
#define map_idx(x, y, len) (((y) * (len)) + (x))

typedef enum tile {
    NONE,
    EAST,
    SOUTH,
} tile_t;

int simulate_step(tile_t *map, int line_len, int lines) {
    int x, y;
    int moved = 0;

    queue q;
    queue_init(&q);

    // east herd
    for (y = 0; y < lines; y++) {
        for (x = 0; x < line_len; x++) {
            int idx = map_idx(x, y, line_len);
            int dest = map_idx((x + 1) % line_len, y, line_len);
            if (map[idx] == EAST && map[dest] == NONE) {
                move_t move;
                move.src_x = x;
                move.src_y = y;
                move.dest_x = (x + 1) % line_len;
                move.dest_y = y;

                push_to_back(&q, move);
            }
        }
    }

    while (!queue_empty(&q)) {
        moved = 1;
        move_t move;
        pop_from_front(&q, &move);

        int src = map_idx(move.src_x, move.src_y, line_len);
        int dest = map_idx(move.dest_x, move.dest_y, line_len);
        map[dest] = map[src];
        map[src] = NONE;
    }

    // south
    for (y = 0; y < lines; y++) {
        for (x = 0; x < line_len; x++) {
            int idx = map_idx(x, y, line_len);
            int dest = map_idx(x, (y + 1) % lines, line_len);
            if (map[idx] == SOUTH && map[dest] == NONE) {
                move_t move;
                move.src_x = x;
                move.src_y = y;
                move.dest_x = x;
                move.dest_y = (y + 1) % lines;

                push_to_back(&q, move);
            }
        }
    }

    while (!queue_empty(&q)) {
        moved = 1;
        move_t move;
        pop_from_front(&q, &move);

        int src = map_idx(move.src_x, move.src_y, line_len);
        int dest = map_idx(move.dest_x, move.dest_y, line_len);
        map[dest] = map[src];
        map[src] = NONE;
    }

    queue_destroy(&q);
    return moved;
}

int main() {
    FILE *input;
    char *file_name = TEST ? "test.txt" : "input.txt";

    if ((input = fopen(file_name, "r")) == NULL) {
        printf("Unable to open file");
        return 1;
    }

    char c;
    int lines = 0;
    int line_len = 0;
    int curr_len = 0;
    while ((c = fgetc(input)) != EOF) {
        if (c == '\n') {
            lines++;
            if (line_len == 0) {
                line_len = curr_len;
            }
            curr_len = 0;
        } else {
            curr_len++;
        }
    }
    rewind(input);

    // access with row * line_len + col / y * line_len + x
    tile_t *map = malloc(lines * line_len * sizeof(tile_t));
    if (map == NULL) {
        perror("Couldn't allocate for map");
        fclose(input);
        return 1;
    }

    int x = 0;
    int y = 0;
    while ((c = fgetc(input)) != EOF) {
        if (c == '\n') {
            y++;
            x = 0;
        } else {
            int idx = map_idx(x, y, line_len);
            if (c == '.') {
                map[idx] = NONE;
            } else if (c == 'v') {
                map[idx] = SOUTH;
            } else if (c == '>') {
                map[idx] = EAST;
            } else {
                printf("unknown character: %c at %d,%d\n", c, x, y);
            }
            x++;
        }
    }
    fclose(input);

    int steps = 0;
    int moved = 0;
    do {
        steps++;
        moved = simulate_step(map, line_len, lines);
    } while (moved);
    free(map);

    printf("Nothing moved on step %d\n", steps);
}
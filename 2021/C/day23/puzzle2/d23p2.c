#include <stdio.h>
#include <stdlib.h>
#include "utils/d23_pqueue.h"

#define TEST 0

burrow_t finished_burrow;

int is_organized(burrow_t *state) {
    burrow_t done = finished_burrow;
    return layouts_equal(state, &done);
}

int is_visited(burrow_t *visited, int visit_num, burrow_t state) {
    for (int i = 0; i < visit_num; i++) {
        if (layouts_equal(&visited[i], &state)) {
            if (visited[i].energy > state.energy) {
                return 0;
            } else {
                return 1;
            }
        }
    }

    return 0;
}

int room_is_eligible(int from, int room_num, burrow_t state) {
    if (state.layout[ROW_HALL][from] != get_room_type_from_num(room_num)) {
        return 0;
    }

    int col = 2 * (room_num + 1);
    if (state.layout[ROW_RM_TOP][col] == EMPTY) {
        if (state.layout[ROW_RM_BTM][col] == EMPTY) {
            return 1;
        } else {
            return state.layout[ROW_RM_BTM][col] == get_room_type_from_num(room_num);
        }
    }

    return 0;
}

int room_is_finished(int room_col, burrow_t state) {
    type_t expected = get_room_type_from_col(room_col);
    for (int row = ROW_RM_TOP; row <= ROW_RM_BTM; row++) {
        if (state.layout[row][room_col] != expected) {
            return 0;
        }
    }
    return 1;
}

int valid_move_from_room(int room_col, burrow_t state) {
    type_t expected = get_room_type_from_col(room_col);
    int first_occupied_row = -1;
    for (int row = ROW_RM_TOP; row <= ROW_RM_BTM; row++) {
        type_t actual = state.layout[row][room_col];
        if (actual != EMPTY) {
            first_occupied_row = row;
            break;
        }
    }

    if (first_occupied_row == -1) {
        return -1;
    }

    for (int row = first_occupied_row; row <= ROW_RM_BTM; row++) {
        type_t actual = state.layout[row][room_col];
        if (actual != expected && actual != EMPTY) {
            return first_occupied_row;
        }
    }

    return -1;
}

burrow_t execute_move(move_t move, burrow_t state, int dist) {

    burrow_t new_state = state;
    if (move.move_type == ROOM_TO_HALL) {
        new_state.layout[ROW_HALL][move.hall] = new_state.layout[move.room_row][move.room_col];
        new_state.layout[move.room_row][move.room_col] = EMPTY;
        new_state.energy += dist * new_state.layout[ROW_HALL][move.hall];
    } else {
        new_state.layout[move.room_row][move.room_col] = new_state.layout[ROW_HALL][move.hall];
        new_state.layout[ROW_HALL][move.hall] = EMPTY;
        new_state.energy += dist * new_state.layout[move.room_row][move.room_col];
    }
    return new_state;
}

int path_move(move_t move, const burrow_t state) {
    int dist = 0;

    if (move.move_type == ROOM_TO_HALL) {
        if (state.layout[ROW_HALL][move.hall] != EMPTY) return 0;
    }

    int step = (move.hall < move.room_col) ? 1 : -1;
    int curr = move.hall;

    while (curr != move.room_col) {
        if (!(move.move_type == HALL_TO_ROOM && curr == move.hall)) {
            if (state.layout[ROW_HALL][curr] != EMPTY) return 0;
        }
        curr += step;
        dist++;
    }

    if (move.move_type == ROOM_TO_HALL && state.layout[ROW_HALL][move.room_col] != EMPTY) {
        return 0;
    }

    dist += move.room_row;

    return dist;
}

int organize_burrow(burrow_t state) {

    int visit_num = 0;
    int visit_cap = 1024;
    burrow_t *visited = (burrow_t *)malloc(visit_cap * sizeof(burrow_t));

    burrow_queue_t pq;
    queue_init(&pq, 1024);
    queue_add(&pq, state);

    int energy = -1;
    while (!queue_is_empty(&pq)) {
        burrow_t current;
        queue_remove(&pq, &current);

        if (is_organized(&current)) {
            energy = current.energy;
            break;
        }

        // refactored block
        if (!is_visited(visited, visit_num, current)) {

            visited[visit_num++] = current;
            if (visit_num >= visit_cap) {
                visit_cap *= 2;
                visited = (burrow_t *)realloc(visited, visit_cap * sizeof(burrow_t));
            }

            // check for hall to room movements
            int to_room = 0;
            for (int h = 0; h < NCOL; h++) {
                if (current.layout[ROW_HALL][h] != EMPTY) {

                    int room_col = get_room_col_from_type(current.layout[ROW_HALL][h]);
                    int room_row = -1;
                    type_t expected = get_room_type_from_col(room_col);
                    for (int i = ROW_RM_BTM; i >= ROW_RM_TOP; i--) {
                        type_t actual = current.layout[i][room_col];
                        if (actual == EMPTY) {
                            // empty spot; we can move here
                            room_row = i;
                            break;
                        } else if (actual != expected) {
                            // foreign amphipod; we cannot move
                            break;
                        }
                    }

                    if (room_row != -1) {
                        move_t move = { HALL_TO_ROOM, h, room_row, room_col };
                        int dist = path_move(move, current);
                        if (dist > 0) {
                            burrow_t new_state = execute_move(move, current, dist);
                            queue_add(&pq, new_state);
                            to_room = 1;
                        }
                    }
                }
            }

            // if no h-t-r, then try r-t-h
            if (!to_room) {
                // for each room, try to queue up a move to each valid hall unblocked hall position
                for (int col = COL_ROOM_A; col <= COL_ROOM_D; col += 2) {
                    int move_row = valid_move_from_room(col, current);
                    if (move_row != -1) {
                        for (int h = 0; h < NCOL; h++) {
                            if (h == COL_ROOM_A || h == COL_ROOM_B || h == COL_ROOM_C || h == COL_ROOM_D) {
                                continue;
                            }

                            move_t move = { ROOM_TO_HALL, h, move_row, col };
                            int dist = path_move(move, current);
                            if (dist > 0) {
                                burrow_t new_state = execute_move(move, current, dist);
                                queue_add(&pq, new_state);
                            }
                        }
                    }
                }
            }
        }
    }

    free(visited);
    queue_free(&pq);
    return energy;
}

burrow_t parse_input(FILE *input) {

    burrow_t state;
    state.energy = 0;

    char str[50];
    fscanf(input, "%[^\n]s", str);
    fgetc(input);
    for (int row = 0; row < NROW; row++) {
        char c = fgetc(input);

        int limit = NCOL;
        if (c == ' ') {
            limit = NCOL - 2;
            for (int col = limit; col < NCOL; col++) {
                state.layout[row][col] = char_to_type('#');
            }
        }

        for (int col = 0; col < limit; col++) {
            state.layout[row][col] = char_to_type(fgetc(input));
        }
        fscanf(input, "%[^\n]s", str);
        fgetc(input);
    }

    return state;
}

int main() {

    FILE *input;
    char *file_name = TEST ? "test_input.txt" : "input.txt";

    if ((input = fopen(file_name, "r")) == NULL) {
        printf("Unable to open file");
        exit(EXIT_FAILURE);
    }

    burrow_t state = parse_input(input);
    fclose(input);

    finished_burrow = get_finished_burrow();

    int dist = organize_burrow(state);
    printf("Energy: %d\n", dist);

    return EXIT_SUCCESS;
}
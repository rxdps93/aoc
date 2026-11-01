#include <stdio.h>

#include "queue.h"

#define TEST 0

int regs[4] = { 0, 0, 0, 0 };
queue q;

int read_register(char reg, int *value) {
    switch (reg) {
        case 'w':
        case 'W':
            *value = regs[0];
            break;
        case 'x':
        case 'X':
            *value = regs[1];
            break;
        case 'y':
        case 'Y':
            *value = regs[2];
            break;
        case 'z':
        case 'Z':
            *value = regs[3];
            break;
        default:
            return FAILURE;
    }

    return SUCCESS;
}

int write_register(char reg, int value) {
    switch (reg) {
        case 'w':
        case 'W':
            regs[0] = value;
            break;
        case 'x':
        case 'X':
            regs[1] = value;
            break;
        case 'y':
        case 'Y':
            regs[2] = value;
            break;
        case 'z':
        case 'Z':
            regs[3] = value;
            break;
        default:
            return FAILURE;
    }

    return SUCCESS;
}

void get_values(char a, int b, int *va, int *vb) {
    read_register(a, va);

    int res = read_register((char)b, vb);
    if (res == FAILURE) {
        *vb = b;
    }
}

void inp_fn(char a) {
    int val;
    pop_from_front(&q, &val);
    write_register(a, val);
}

void add_fn(char a, int b) {
    int val_a, val_b;
    get_values(a, b, &val_a, &val_b);
    write_register(a, val_a + val_b);
}

void mul_fn(char a, int b) {
    int val_a, val_b;
    get_values(a, b, &val_a, &val_b);
    write_register(a, val_a * val_b);
}

void div_fn(char a, int b) {
    int val_a, val_b;
    get_values(a, b, &val_a, &val_b);
    write_register(a, val_a / val_b);
}

void mod_fn(char a, int b) {
    int val_a, val_b;
    get_values(a, b, &val_a, &val_b);
    write_register(a, val_a % val_b);
}

void eql_fn(char a, int b) {
    int val_a, val_b;
    get_values(a, b, &val_a, &val_b);
    write_register(a, val_a == val_b);
}

void print_registers() {
    printf("[");
    for (int i = 0; i < 4; i++) {
        printf(" %d", regs[i]);
    }
    printf(" ]\n");
}

void exec_fn(char fn[4], char a, int b) {
    switch (fn[1]) {
        case 'd': // add
            add_fn(a, b);
            break;
        case 'u': // mul
            mul_fn(a, b);
            break;
        case 'i': // div
            div_fn(a, b);
            break;
        case 'o': // mod
            mod_fn(a, b);
            break;
        case 'q': // eql
            eql_fn(a, b);
            break;
    }
}

int is_register(char c) {
    switch (c) {
        case 'w':
        case 'W':
        case 'x':
        case 'X':
        case 'y':
        case 'Y':
        case 'z':
        case 'Z':
            return SUCCESS;
        default:
            return FAILURE;
    }
}

void exec_prgm(FILE *input, int digits[14]) {
    for (int i = 0; i < 4; i++) {
        regs[i] = 0;
    }
    rewind(input);
    queue_init(&q);

    for (int i = 0; i < 14; i++) {
        push_to_back(&q, digits[i]);
    }

    char buffer[32];
    char fn[4];
    char a;
    char b_str[32];
    while(fgets(buffer, sizeof(buffer), input) != NULL) {
        int items = sscanf(buffer, "%3s %c %s", fn, &a, b_str);

        if (items <= 0) {
            continue;
        } else if (items == 2) {
            inp_fn(a);
        } else if (items == 3) {
            int b;
            if (is_register(b_str[0]) == SUCCESS) {
                b = (char)b_str[0];
            } else {
                b = strtol(b_str, NULL, 10);
            }
            exec_fn(fn, a, b);
        } else {
            printf("something went wrong parsing:\n\t%s\n", buffer);
            break;
        }
	}

    queue_destroy(&q);
}

int main() {
    FILE *input;
    char *file_name = TEST ? "test.txt" : "input.txt";

    if ((input = fopen(file_name, "r")) == NULL) {
        printf("Unable to open file");
        return 1;
    }
    queue_init(&q);

    printf("See analysis.md; this was largely solved by hand outside of the code.\n");

    // calculated serials from analysis.md
    int part_one[14] = { 9, 2, 9, 6, 9, 5, 9, 3, 4, 9, 7, 9, 9, 2 };
    int part_two[14] = { 8, 1, 5, 1, 4, 1, 7, 1, 1, 6, 1, 3, 8, 1 };

    exec_prgm(input, part_one);
    printf("Part 1:\n");
    print_registers();
    for (int i = 0; i < 14; i++) {
        printf("%d", part_one[i]);
    }
    printf("\n\n");

    exec_prgm(input, part_two);
    printf("Part 2:\n");
    print_registers();
    for (int i = 0; i < 14; i++) {
        printf("%d", part_two[i]);
    }
    printf("\n");

    fclose(input);

    return 0;
}
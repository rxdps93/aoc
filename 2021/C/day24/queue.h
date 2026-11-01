#include <stdio.h>
#include <stdlib.h>

#define SUCCESS 0
#define FAILURE -1

typedef struct node {
    int data;
    struct node *next;
} node_t;

typedef struct {
    node_t *head;
    node_t *tail;
} queue;

void queue_init(queue *q) {
    q->head = NULL;
    q->tail = NULL;
}

void queue_destroy(queue *q) {
    node_t *current = q->head;
    node_t *next;

    while (current != NULL) {
        next = current->next;
        free(current);
        current = next;
    }

    q->head = NULL;
    q->tail = NULL;
}

int queue_empty(queue *q) {
    return q->head == NULL;
}

int push_to_back(queue *q, int value) {
    node_t *node = (node_t *)malloc(sizeof(node));
    if (!node) {
        printf("Could not allocate memory for queue\n");
        return FAILURE;
    }

    node->data = value;
    node->next = NULL;

    if (queue_empty(q)) {
        q->head = node;
        q->tail = node;
    } else {
        q->tail->next = node;
        q->tail = node;
    }

    return SUCCESS;
}

int pop_from_front(queue *q, int *value) {
    if (queue_empty(q)) {
        printf("Queue empty\n");
        return -1;
    }

    node_t *temp = q->head;
    *value = temp->data;

    q->head = q->head->next;
    if (q->head == NULL) {
        q->tail = NULL;
    }

    free(temp);
    return SUCCESS;
}
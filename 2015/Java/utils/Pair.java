package utils;

public class Pair<K, V> {
    private final K first;
    private final V second;

    private Pair(K first, V second) {
        this.first = first;
        this.second = second;
    }

    public K first() {
        return this.first;
    }

    public V second() {
        return this.second;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }

        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        Pair<?, ?> pair = (Pair<?, ?>)o;
        if (!first.equals(pair.first)) {
            return false;
        }
        return second.equals(pair.second);
    }

    @Override
    public int hashCode() {
        return 121120 * first.hashCode() + second.hashCode();
    }

    @Override
    public String toString() {
        return String.format("( %s, %s )", this.first.toString(), this.second.toString());
    }

    public static <K, V> Pair<K, V> of(K first, V second) {
        return new Pair<>(first, second);
    }
}

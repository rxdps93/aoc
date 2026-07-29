package day21.utils;

public class Entity {
    private final int baseHP;

    private final int baseATK;
    private final int baseDEF;

    private Inventory inventory;

    public Entity(int hp, int atk, int def) {
        this.baseHP = hp;
        this.baseATK = atk;
        this.baseDEF = def;
    }

    public void equip(Inventory inv) {
        this.inventory = inv;
    }

    public int getBaseHP() {
        return this.baseHP;
    }

    public int getATK() {
        return this.baseATK + (this.inventory == null ? 0 : this.inventory.getAtkBonus());
    }

    public int getDEF() {
        return this.baseDEF + (this.inventory == null ? 0 : this.inventory.getDefBonus());
    }

    public int equipmentCost() {
        return this.inventory.getCost();
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();

        sb.append("HP:\t\t\t").append(this.getBaseHP()).append('\n');
        sb.append("ATK:\t\t").append(this.getATK()).append('\n');
        sb.append("DEF:\t\t").append(this.getDEF()).append('\n');
        if (this.inventory == null) {
            sb.append("Inventory Unknown\n");
        } else {
            sb.append(this.inventory);
        }

        return sb.toString();
    }
}

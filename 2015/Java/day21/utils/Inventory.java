package day21.utils;

public class Inventory {

    private final Weapon weapon;
    private final Armor armor;
    private final Ring ringLeft;
    private final Ring ringRight;

    public Inventory(Weapon w, Armor a, Ring rl, Ring rr) {
        this.weapon = w;
        this.armor = a;
        if (rl == rr) {
            System.out.println("hi");
            this.ringLeft = null;
            this.ringRight = null;
        } else {
            this.ringLeft = rl;
            this.ringRight = rr;
        }
    }

    public Weapon getWeapon() {
        return this.weapon;
    }

    public Armor getArmor() {
        return this.armor;
    }

    public Ring getRingLeft() {
        return this.ringLeft;
    }

    public Ring getRingRight() {
        return this.ringRight;
    }

    public int getAtkBonus() {
        return (this.weapon != null ? this.weapon.getValue() : 0) +
                (this.ringLeft != null ? this.ringLeft.getAtk() : 0) +
                (this.ringRight != null ? this.ringRight.getAtk() : 0);
    }

    public int getDefBonus() {
        return (this.armor != null ? this.armor.getValue() : 0) +
                (this.ringLeft != null ? this.ringLeft.getDef() : 0) +
                (this.ringRight != null ? this.ringRight.getDef() : 0);
    }

    public int getCost() {
        return (this.weapon != null ? this.weapon.getCost() : 0) +
                (this.armor != null ? this.armor.getCost() : 0) +
                (this.ringLeft != null ? this.ringLeft.getCost() : 0) +
                (this.ringRight != null ? this.ringRight.getCost() : 0);
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();

        sb.append("EQUIPMENT: [ ").append(this.getCost()).append(" gp ]\n");
        sb.append("Weapon:\t\t").append(this.weapon == null ? "None" : this.weapon).append('\n');
        sb.append("Armor:\t\t").append(this.armor == null ? "None" : this.armor).append('\n');
        sb.append("Left Ring:\t").append(this.ringLeft == null ? "None" : this.ringLeft).append('\n');
        sb.append("Right Ring:\t").append(this.ringRight == null ? "None" : this.ringRight).append('\n');

        return sb.toString();
    }
}

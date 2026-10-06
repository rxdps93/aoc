package main

import "core:os"
import "core:strings"
import "core:strconv"
import "core:fmt"
import "core:slice"

Side :: enum {
    None,
    Immune_System,
    Infection,
}

Group :: struct {
    side: Side,
    target: ^Group,
    is_targeted: bool,
    units: int,
    hp: int,
    dmg: int,
    type: string,
    weaknesses: [dynamic]string,
    immunities: [dynamic]string,
    initiative: int,
}

parse_input :: proc(groups: ^[dynamic]^Group, lines: []string) {
    /*
        input follows this pattern:
        W units each with X hit points
        [([weak/immune to ...]; [weak/immune to ...])]
        with an attack that does Y [type] damage at initiative Z
    */

    current_side := Side.Immune_System
    for line in lines {
        if strings.contains(line, "Immune System") {
            current_side = .Immune_System
            continue
        } else if strings.contains(line, "Infection") {
            current_side = .Infection
            continue
        } else if len(line) == 0 {
            continue
        }

        group := new(Group)
        str := line

        // check for optional attributes block
        if strings.contains(line, "(") {
            start := strings.index_rune(line, '(')
            end := strings.index_rune(line, ')')

            attributes := strings.split(line[start + 1:end], "; ", context.temp_allocator)
            str = strings.concatenate({line[:start], strings.trim_space(line[end + 1:])}, context.temp_allocator)

            for attribute in attributes {
                if strings.has_prefix(attribute, "weak to ") {
                    types := strings.split(attribute[8:], ", ", context.temp_allocator)
                    append_elems(&group.weaknesses, ..types)
                } else if strings.has_prefix(attribute, "immune to ") {
                    types := strings.split(attribute[10:], ", ", context.temp_allocator)
                    append_elems(&group.immunities, ..types)
                }
            }
        }

        stats := strings.fields(str, context.temp_allocator)
        group.side          = current_side
        group.target        = nil
        group.units, _      = strconv.parse_int(stats[0])
        group.hp, _         = strconv.parse_int(stats[4])
        group.dmg, _        = strconv.parse_int(stats[12])
        group.type          = stats[13]
        group.initiative, _ = strconv.parse_int(stats[17])

        append(groups, group)
    }
}

calculate_damage_dealt :: proc(attacker, defender: Group) -> int {
    if slice.contains(defender.immunities[:], attacker.type) do return 0

    atk_ep := attacker.dmg * attacker.units
    
    if slice.contains(defender.weaknesses[:], attacker.type) do return atk_ep * 2
    
    return atk_ep
}

assign_targets :: proc(groups: ^[dynamic]^Group) {
    for group in groups {
        group.is_targeted = false
        group.target = nil
    }

    for atk, ai in groups {
        target_ptr: ^Group = nil
        dmg_taken := min(int)
        target_ep := min(int)
        init := min(int)
        for target in groups {
            if atk.side == target.side do continue
            if target.is_targeted == true do continue

            dmg := calculate_damage_dealt(atk^, target^)
            if dmg == 0 do continue
            if dmg > dmg_taken {
                target_ptr = target
                dmg_taken = dmg
                target_ep = target.dmg * target.units
                init = target.initiative
            } else if dmg == dmg_taken {
                if (target.dmg * target.units) < target_ep do continue
                if (target.dmg * target.units) == target_ep && target.initiative < init do continue
                target_ptr = target
                dmg_taken = dmg
                target_ep = target.dmg * target.units
                init = target.initiative
            }
        }

        if target_ptr != nil {
            atk.target = target_ptr
            target_ptr.is_targeted = true
        }
    }
}

simulate_combat :: proc(groups: ^[dynamic]^Group) -> (winning_side: Side, winning_units: int) {
    immune_left, infect_left := true, true
    for immune_left && infect_left {
        // 1. target selection phase
        // a. sort by effective power and then initiative
        // b. choose group that would take the most dmg
        // c. ties are broken by choosing the largest effective power
        // d. further ties are broken by choosing the one with higher initiative
        // e. it is possible to not choose a target
        slice.sort_by(groups[:], proc(a, b: ^Group) -> bool {
            a_pwr := a.dmg * a.units
            b_pwr := b.dmg * b.units
            if a_pwr != b_pwr do return a_pwr > b_pwr
            return a.initiative > b.initiative
        })

        assign_targets(groups)

        // 2. attacking phase
        // a. go through in order of decreasing initiative
        // b. make sure attacker has a target
        // c. make sure target has units remaining
        // d. target loses whole units only
        // e. remaining damage is discarded/not dealt
        slice.sort_by(groups[:], proc(a, b: ^Group) -> bool {
            return a.initiative > b.initiative
        })

        total_units_lost := 0
        for attacker in groups {
            if attacker.units <= 0 do continue
            if attacker.target == nil do continue
            if attacker.target.units <= 0 do continue
            if calculate_damage_dealt(attacker^, attacker.target^) < attacker.target.hp do continue

            units_lost := calculate_damage_dealt(attacker^, attacker.target^) / attacker.target.hp
            units_lost = min(attacker.target.units, units_lost)
            attacker.target.units -= units_lost
            total_units_lost += units_lost
        }

        for i := 0; i < len(groups); {
            if groups[i].units <= 0 {
                free_group(groups[i])
                unordered_remove(groups, i)
            } else {
                i += 1
            }
        }

        immune_left, infect_left = false, false
        for g in groups {
            if g.side == .Immune_System {
                immune_left = true
            } else {
                infect_left = true
            }
        }

        if total_units_lost == 0 do break
    }

    if immune_left && infect_left do return .None, -1

    remainder := 0
    for g in groups {
        if immune_left && g.side == .Immune_System {
            remainder += g.units
        } else if infect_left && g.side == .Infection {
            remainder += g.units
        }
    }
    return (immune_left ? .Immune_System : .Infection), remainder
}

clone_groups :: proc(original: []^Group, boost: int) -> [dynamic]^Group {
    clone := make([dynamic]^Group, len(original))
    for g, i in original {
        clone[i] = new(Group)
        clone[i]^ = g^

        clone[i].weaknesses = slice.clone_to_dynamic(g.weaknesses[:])
        clone[i].immunities = slice.clone_to_dynamic(g.immunities[:])

        if g.side == .Immune_System {
            clone[i].dmg += boost
        }
    }
    return clone
}

free_group :: proc(group: ^Group) {
    delete(group.weaknesses)
    delete(group.immunities)
    free(group)
}

main :: proc() {
    input, err := os.read_entire_file("input.txt", context.temp_allocator)
    if err != nil do return

    groups := make([dynamic]^Group)
    defer {
        for group in groups {
            free_group(group)
        }
        delete(groups)
    }

    lines := strings.split_lines(string(input), context.temp_allocator)
    parse_input(&groups, lines)

    boost := 0
    winner := Side.None
    units := 0
    for boost = 0;;boost += 1 {
        combatants := clone_groups(groups[:], boost)
        winner, units = simulate_combat(&combatants)

        for group in combatants {
            free_group(group)
        }
        delete(combatants)

        if boost == 0 {
            fmt.println(units)
            continue
        }

        if winner == .Immune_System do break
    }
    fmt.println(units)
}
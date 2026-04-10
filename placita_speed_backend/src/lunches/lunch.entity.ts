import { Entity, Column, PrimaryGeneratedColumn } from "typeorm";

@Entity()
export class Lunch {
    @PrimaryGeneratedColumn()
    lunch_id: number

    @Column({type: 'varchar', length: 60, unique: true})
    name: string

    @Column({type: 'varchar', length: 200})
    description: string

    @Column({type: 'decimal', precision: 10, scale: 2})
    virtual_price: number

    @Column({type: 'int'})
    stock: number
}
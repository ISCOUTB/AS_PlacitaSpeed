export abstract class RepositoryPort<classname> {
    abstract findAll(): Promise<classname[]>;
    abstract create(entity: classname): Promise<classname>;
    abstract update(entity: classname): void;
}
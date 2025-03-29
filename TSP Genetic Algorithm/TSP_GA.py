import numpy as np
import random

#example data:
CITIES = np.array([
[0, 0], [1, 5], [5, 2], [6, 6], [8, 3]
])

#algorithm default parameters
POPULATION_SIZE = 10
NUMBER_OF_GENERATIONS = 1000
MUTATION_RATE = 0.01

#generate initial TSP population of given size (pop_size)
def generate_population(cities, pop_size):
    length = int(((cities.size)/2)+1)
    population =  np.array([np.random.permutation(length-1) for _ in range(pop_size)])
    return np.array([np.append(route, route[0]) for route in population])
    
#calculate distance between chosen cities
def euclidean_distance(city1, city2):
    return np.sqrt(np.sum((city1 - city2) ** 2))

#calculate route length - fitness function
def total_route_distance(route, cities):
    distance = 0
    for i in range(len(route) - 1):
        city_a = cities[route[i]]
        city_b = cities[route[i + 1]]
        distance += euclidean_distance(city_a, city_b)
    return distance

#selection - tournament selection
def selection(cities, population, pop_size):
    if(pop_size%4 == 0): #there must be even number of parents
        eligible = int(pop_size/2)       #how many of them can reproduce
    else:
        eligible = int((pop_size)/2)-1
        
    scores = np.zeros(pop_size)
    
    for i in range(pop_size):
        scores[i] = total_route_distance(population[i], cities)

    #make array ascending, to make first the best route
    indices = np.argsort(scores)    #indices which would make scores sorted asc
    return(population[indices], eligible, scores[indices])      #returns sorted array (easier to work with later) and how many are eligible for reproduction and distances by index of route
        
#crossover - to make a child for two routes - OX
def crossover(route1, route2, cities):
    route1 = route1[:-1]
    route2 = route2[:-1]

    length = route1.size

    subsection_length = random.randrange(1,length,1)
    subsection_start = random.randrange(0,length-subsection_length+1,1)

    subsection1 = route1[subsection_start:subsection_start+subsection_length]

    child = np.zeros(length)
    child[subsection_start:subsection_start+subsection_length] = subsection1

    child_index = 0

    for i in range(length):
        if not route2[i] in child:
            while child[child_index] != 0:
                child_index = child_index+1
            child[child_index] = route2[i]
        
    child = np.append(child, child[0])
    child= child.astype(int)

    #calculate route lentgh
    length = total_route_distance(child, cities)
    return child, length

#mutation of a route by swapping values
def mutate(route, cities):
    route = route[:-1]
    rand1 = random.randrange(0,route.size)
    while (True):
        rand2 = random.randrange(0,route.size)
        if rand1 != rand2:
            break

    #swap values
    tmp = route[rand1]
    route[rand1] = route[rand2]
    route[rand2] = tmp

    route = np.append(route, route[0])
    distance = total_route_distance(route, cities)
    return route, distance

#delete the weakest
def purge(population, population_size, distances):
    # Sort population by fitness (ascending order)
    indices = np.argsort(distances)
    population = population[indices]

    # Keep the best population_size individuals
    return population[:population_size], distances[:population_size]

#final algorithm
def TSP_genetic_algorithm(cities, population, population_size, mutation_rate, number_of_generations):
    #main loop, runs for i generations
    for i in range(number_of_generations):
        #select population for breeding
        sorted_population, indices, distances = selection(cities, population, population_size)
        for i in range(0,indices,2):
            child, child_length = crossover(sorted_population[i], sorted_population[i+1], CITIES)
            population = np.vstack([population, child])
            distances = np.append(distances, child_length)
            

        #make array ascending, to make first the best route
        indices = np.argsort(distances)    #indices which would make scores sorted asc

        population = population[indices]
        distances = distances[indices]

        #apply mutation
        for i in range(population_size):
            if random.random() < mutation_rate:
                population[i], distances[i] = mutate(population[i], cities)

        #delete weakest
        population, distances = purge(population, population_size, distances)        

        route = population[0]
        length = distances[0]

    return route, length


if __name__ == '__main__':
    pop = generate_population(CITIES, POPULATION_SIZE)
    r, l = TSP_genetic_algorithm(CITIES, pop, POPULATION_SIZE, MUTATION_RATE, NUMBER_OF_GENERATIONS)
    print(r,l)

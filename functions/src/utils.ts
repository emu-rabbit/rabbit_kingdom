/* eslint-disable require-jsdoc */
export function limitConcurrency<T>(
  tasks: (() => Promise<T>)[],
  limit: number
): Promise<T[]> {
  const results: T[] = [];
  let index = 0;
  let active = 0;

  return new Promise((resolve, reject) => {
    function runNext() {
      if (index >= tasks.length && active === 0) return resolve(results);
      while (active < limit && index < tasks.length) {
        const current = index++;
        active++;
        tasks[current]()
          .then((result) => {
            results[current] = result;
            active--;
            runNext();
          })
          .catch(reject);
      }
    }
    runNext();
  });
}

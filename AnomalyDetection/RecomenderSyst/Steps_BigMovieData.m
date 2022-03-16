clear;
dataset = 'ml-latest-small';
fname = 'movie-ratings.zip';
websave(fname,['http://files.grouplens.org/datasets/movielens/',dataset,'.zip']);
unzip(fname);
delete(fname);


moviesTbl = readtable([pwd '/', dataset, '/movies.csv'],'Delimiter',',','TextType','string')
  
  
  
 n = length(moviesTbl.title);
year = zeros(n,1);
for i = 1:n
    str = extractBetween(moviesTbl.title(i),'(',')');
    if isempty(str)
        % Missing year
        year(i) = nan;
    else
        % In case of multiple parentheses, use last string extracted
        year(i) = str2double(str(end)); 
    end
end
inds = moviesTbl.movieId(isnan(year));
moviesTbl.year = year


% Obtain a list of all unique genres in the dictionary
Genres = join(moviesTbl.genres,'|');
Genres = unique(split(Genres,'|'));
Genres(1) = []; % Remove 'no genres' genre
% Create a logical variable for each genre
genres = arrayfun(@(Genres)contains(moviesTbl.genres,Genres),Genres','UniformOutput',false);
% Add the genre variables to the dictionary
moviesTbl = addvars(moviesTbl,genres{:},'NewVariableNames',lower(replace(Genres,'-','')));
% Remove the original genre variable
moviesTbl = removevars(moviesTbl,'genres')


ratingsDS = tabularTextDatastore([pwd '/', dataset, '/ratings.csv'],...
    'SelectedVariableNames',{'userId','movieId','rating'})
preview(ratingsDS)

ratingsTbl = tall(ratingsDS)

nr = height(ratingsTbl);
nr = gather(nr);
printf('There are %d total ratings in the dataset',nr)

ratingsTbl(ismember(ratingsTbl.movieId,inds),:) = [];
counts = histcounts(ratingsTbl.userId,'BinMethod','Integers');
counts = gather(counts);

nu = length(counts);
[counts,usid] = max(counts);
fprintf('There are %d unique user ID''s in the dataset',nu)

fprintf('The most prolific reviewer in the dataset has user ID %d and has %d reviews.',usid,counts)

globalMean = gather(mean(ratingsTbl.rating));
fprintf('The mean movie rating is: %.4f', globalMean)
histogram(categorical(ratingsTbl.rating))



ratingsTbl = join(ratingsTbl,moviesTbl)

[grp,inds] = findgroups(ratingsTbl.movieId);
inds = gather(inds);

nm = length(inds);
fprintf('There are %d unique movies in the ratings dataset',nm)

ratingsTbl.movieId = grp

numRatings = gather(histcounts(ratingsTbl.movieId,'BinMethod','integers'));

[count,ind] = max(numRatings);
ttl = gather(ratingsTbl.title(find(ratingsTbl.movieId==ind,1)));

fprintf('The most reviewed movie in the dataset is ''%s'' with %d reviews',ttl, count);

histogram(numRatings,'BinWidth',10)
xlabel('# of Reviews')

titles = "Star Wars: Episode " + ["IV","V","VI"] + " "

inds = contains(ratingsTbl.title,titles);
rtg =  gather(mean(ratingsTbl.rating(inds)));

fprintf('The mean rating for the original Star Wars trilogy is: %.2f',rtg);

titles = "Star Wars: Episode " + ["I","II","III"] + " "

rtg = gather(mean(ratingsTbl.rating(contains(ratingsTbl.title,titles))));

fprintf('The mean rating for the Star Wars prequels is: %.2f',rtg);


                 
                  
[means,sums,grp] = grpstats(ratingsTbl.rating,ratingsTbl.year,{'mean','numel','gname'});
[means,sums,grp] = gather(means,sums,grp);
figure; hold on;
yyaxis left;
plot(str2double(grp),means,'b.','MarkerSize',6);
yyaxis right;
plot(str2double(grp),sums,'rsq','MarkerSize',6);
legend({'Mean rating','# of ratings'})

figure;
plot(sums,means,'diamond')
title('Ratings grouped by year')
xlabel('Number of ratings')
ylabel('Mean rating')


                  
err = gather(mean(abs(ratingsTbl.rating-globalMean)));
fprintf('The mean absolute prediction error using the overall mean rating is: %g',err);

                  
meanRating = gather(splitapply(@mean,ratingsTbl.rating,ratingsTbl.movieId));
ratingsTbl = join(ratingsTbl,array2table([(1:nm)',meanRating,numRatings'],'VariableNames',{'movieId','meanRating','numRatings'}));
meanPred = ratingsTbl.meanRating;
meanPred(ratingsTbl.numRatings<10) = globalMean;
meanPredErr = mean(abs(meanPred-ratingsTbl.rating));
fprintf('The mean absolute error when predicting the mean rating by movie is: %g',gather(meanPredErr))
                  
                  
tbl = unique(ratingsTbl(:,[2,4,5,end-1,end,6:end-2]),'rows');
tbl = gather(tbl)
tbl = sortrows(tbl,'year','descend')

